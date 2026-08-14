
import Foundation

final class BinanceAPI: ApiInterface {

    enum Host: String {
        case main = "https://fapi.binance.com"
        case spot = "https://api.binance.com"
    }

    enum Interval: String, Sendable, Hashable {
        case min1 = "1m"
        case min3 = "3m"
        case min5 = "5m"
        case min15 = "15m"
        case min30 = "30m"
        case min60 = "1h"
        case min240 = "4h"
        case day1 = "1d"
    }

    var host: Host = .main
    var session: URLSession = .shared

    fileprivate let cexRPMService: CexRPMService
    private static let tickersCacheMaxAge: TimeInterval = 60 * 60
    private static let exchangeInfoCacheFileName = "exchangeInfo_Binance.json"
    private let exchangeInfoCache = ExchangeInfoCache()

    private actor ExchangeInfoCache {
        private var launchDatesBySymbol: [String: Date]?
        private var updateTask: Task<[String: Date], Error>?

        func launchDate(
            for symbol: String,
            fetch: @escaping @Sendable () async throws -> [String: Date]
        ) async throws -> Date? {
            if let launchDate = launchDatesBySymbol?[symbol] {
                return launchDate
            }

            if let updateTask {
                return try await updateTask.value[symbol]
            }

            let task = Task { try await fetch() }
            updateTask = task

            do {
                let launchDatesBySymbol = try await task.value
                self.launchDatesBySymbol = launchDatesBySymbol
                updateTask = nil
                return launchDatesBySymbol[symbol]
            } catch {
                updateTask = nil
                throw error
            }
        }
    }

    init(cexRPMService: CexRPMService) {
        self.cexRPMService = cexRPMService
    }

    fileprivate func endpoint(_ path: String, market: Cex.Market) -> String {
        switch market {
        case .futures:
            return host.rawValue + "/fapi/v1/\(path)"
        case .spot:
            return Host.spot.rawValue + "/api/v3/\(path)"
        }
    }

    fileprivate func tickersCacheFileName(for market: Cex.Market) -> String {
        switch market {
        case .futures:
            return "tickers_Binance.json"
        case .spot:
            return "tickers_Binance_spot.json"
        }
    }
}

extension BinanceAPI {

    func launchDate(_ symbol: String, market: Cex.Market) async throws -> Date? {
        guard market == .futures else {
            return nil
        }

        guard let launchDate = try await exchangeInfoCache.launchDate(for: symbol, fetch: { [self] in
            try await exchangeInfoLaunchDates(requiredSymbol: symbol)
        }) else {
            throw ApiInterfaceError.launchDateNotFound(symbol: symbol)
        }
        return launchDate
    }

    private func exchangeInfoLaunchDates(requiredSymbol: String) async throws -> [String: Date] {
        do {
            if let cachedData = try await FileService.shared.read(Self.exchangeInfoCacheFileName) {
                let cachedLaunchDates = try exchangeInfoLaunchDates(data: cachedData)
                if cachedLaunchDates[requiredSymbol] != nil {
                    return cachedLaunchDates
                }
                print("Symbol \(requiredSymbol) is missing from cached Binance exchangeInfo, refreshing cache.")
            }
        } catch {
            print("Binance exchangeInfo cache is broken, fetching from API. \(error)")
        }

        let url = URL(string: endpoint("exchangeInfo", market: .futures))!
        cexRPMService.increment(.binance, market: .futures, api: .exchangeInfo)
        let data = try await self.data(url, session: session)
        let launchDates = try exchangeInfoLaunchDates(data: data)
        try await FileService.shared.write(data, name: Self.exchangeInfoCacheFileName)
        return launchDates
    }

    private func exchangeInfoLaunchDates(data: Data) throws -> [String: Date] {
        struct ExchangeInfo: Decodable {
            let symbols: [Symbol]

            struct Symbol: Decodable {
                let symbol: String
                let onboardDate: Int64
            }
        }

        let exchangeInfo = try JSONDecoder().decode(ExchangeInfo.self, from: data)
        return exchangeInfo.symbols.reduce(into: [:]) { launchDatesBySymbol, symbol in
            guard symbol.onboardDate > 0 else {
                return
            }
            launchDatesBySymbol[symbol.symbol] = Date(
                timeIntervalSince1970: TimeInterval(symbol.onboardDate) / 1000.0
            )
        }
    }

    enum ApiInterfaceError: Error, Sendable, LocalizedError {
        case launchDateNotFound(symbol: String)

        var errorDescription: String? {
            switch self {
            case .launchDateNotFound(let symbol):
                return "Launch date not found: \(symbol)"
            }
        }
    }
}

extension BinanceAPI {

    typealias Candle = Cex.Candle

    /// limit: 1...1500 (default 500)
    /// interval: 1, 3, 5, 15, 30, 60
    func kLines(_ symbol: String, market: Cex.Market, interval: Cex.Interval, limit: Int) async throws -> [Candle] {
        try await kLines(symbol, market: market, interval: interval.binance, limit: limit)
    }

    func kLines(_ symbol: String, market: Cex.Market, interval: Interval, limit: Int) async throws -> [Candle] {
        var components = URLComponents(string: endpoint("klines", market: market))
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: interval.rawValue),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        cexRPMService.increment(.binance, market: market, api: .kLines(limit: limit))
        let data = try await self.data(url!, session: session)

        // Binance returns array of arrays directly
        let result = try JSONDecoder().decode([[JSONValue]].self, from: data)
        return result.map { arr -> Candle in
            Candle(
                startTime: TimeInterval(arr[0].doubleValue) / 1000.0,
                open: Double(arr[1].stringValue)!,
                high: Double(arr[2].stringValue)!,
                low: Double(arr[3].stringValue)!,
                close: Double(arr[4].stringValue)!,
                turnover: Double(arr[7].stringValue)!
            )
        }
    }

    // Helper for mixed JSON types
    private enum JSONValue: Decodable {
        case int(Int)
        case double(Double)
        case string(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let int = try? container.decode(Int.self) {
                self = .int(int)
            } else if let double = try? container.decode(Double.self) {
                self = .double(double)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int, Double, or String"))
            }
        }

        var doubleValue: Double {
            switch self {
            case .int(let v): return Double(v)
            case .double(let v): return v
            case .string(let v): return Double(v) ?? 0
            }
        }

        var stringValue: String {
            switch self {
            case .int(let v): return "\(v)"
            case .double(let v): return "\(v)"
            case .string(let v): return v
            }
        }
    }
}

extension BinanceAPI {

    typealias Orderbook = Cex.Orderbook

    func orderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook {
        cexRPMService.increment(.binance, market: market, api: .orderbook)
        return try await _orderbook(symbol, market: market, path: "depth", limit: 1000)
    }

    func rpiOrderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook? {
        guard market == .futures else {
            return nil
        }

        cexRPMService.increment(.binance, market: market, api: .rpiOrderbook)
        return try await _orderbook(symbol, market: market, path: "rpiDepth", limit: 1000)
    }

    private func _orderbook(_ symbol: String, market: Cex.Market, path: String, limit: Int) async throws -> Orderbook {
        var components = URLComponents(string: endpoint(path, market: market))
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)

        struct Holder: Decodable {
            let T: Int64?  // Transaction time. Spot depth responses do not include it.
            let bids: [[String]]
            let asks: [[String]]
        }

        let holder = try JSONDecoder().decode(Holder.self, from: data)
        return Orderbook(
            symbol: symbol,
            bids: holder.bids.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            asks: holder.asks.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            timestamp: holder.T.map { TimeInterval($0) / 1000.0 } ?? Date().timeIntervalSince1970
        )
    }
}

extension BinanceAPI {

    typealias Ticker = Cex.Ticker

    func tickers(_ market: Cex.Market, cache: Bool = false) async throws -> [Ticker] {
        var tickers: [Ticker] = []
        if cache {
            do {
                tickers = try await tickersCache(market)
            } catch {
                print("Cache is broken, fetching from API. \(error)")
            }
        }
        if !tickers.isEmpty {
            return tickers
        }
        print("Fetching \(market.title) tickers from Binance API.")
        let components = URLComponents(string: endpoint("ticker/24hr", market: market))
        let url = components?.url!
        cexRPMService.increment(.binance, market: market, api: .tickers)
        let data = try await self.data(url!, session: session)
        try await FileService.shared.write(data, name: tickersCacheFileName(for: market))
        return try fetch24hrTickers(data: data, market: market)
    }

    func ticker(_ symbol: String, market: Cex.Market) async throws -> Ticker {
        var components = URLComponents(string: endpoint("ticker/24hr", market: market))
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol)
        ]
        let url = components?.url!
        cexRPMService.increment(.binance, market: market, api: .ticker)
        let data = try await self.data(url!, session: session)
        return try fetch24hrTicker(data: data, market: market)
    }

    private func tickersCache(_ market: Cex.Market) async throws -> [Ticker] {
        if let data = try await FileService.shared.read(
            tickersCacheFileName(for: market),
            maxAge: Self.tickersCacheMaxAge
        ) {
            return try fetch24hrTickers(data: data, market: market)
        }
        return []
    }

    private func fetch24hrTickers(data: Data, market: Cex.Market) throws -> [Ticker] {
        return try JSONDecoder().decode([TickerData].self, from: data).map { ticker in
            self.ticker(from: ticker, market: market)
        }
    }

    private func fetch24hrTicker(data: Data, market: Cex.Market) throws -> Ticker {
        return ticker(from: try JSONDecoder().decode(TickerData.self, from: data), market: market)
    }

    private func ticker(from ticker: TickerData, market: Cex.Market) -> Ticker {
        Ticker(
            symbol: ticker.symbol,
            turnover24h: ticker.quoteVolumeDouble,
            priceChangePercent: ticker.priceChangePercentDouble,
            market: market
        )
    }

    private struct TickerData: Decodable {
        let symbol: String
        let quoteVolume: String?
        let priceChangePercent: String?

        var quoteVolumeDouble: Double { Double(quoteVolume ?? "0") ?? 0 }
        var priceChangePercentDouble: Double { Double(priceChangePercent ?? "0") ?? 0 }
    }
}
