
import Foundation

final class BinanceAPI: ApiInterface {

    enum Host: String {
        case main = "https://fapi.binance.com"
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

    init(cexRPMService: CexRPMService) {
        self.cexRPMService = cexRPMService
    }
}

extension BinanceAPI {

    typealias Candle = Cex.Candle

    /// limit: 1...1500 (default 500)
    /// interval: 1, 3, 5, 15, 30, 60
    func kLines(_ symbol: String, interval: Cex.Interval, limit: Int) async throws -> [Candle] {
        try await kLines(symbol, interval: interval.binance, limit: limit)
    }

    func kLines(_ symbol: String, interval: Interval, limit: Int) async throws -> [Candle] {
        var components = URLComponents(string: host.rawValue + "/fapi/v1/klines")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: interval.rawValue),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        cexRPMService.increment(.binance, api: .kLines(limit: limit))
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

    func orderbook(_ symbol: String) async throws -> Orderbook {
        cexRPMService.increment(.binance, api: .orderbook)
        return try await _orderbook(symbol, path: "depth", limit: 1000)
    }

    func rpiOrderbook(_ symbol: String) async throws -> Orderbook {
        cexRPMService.increment(.binance, api: .rpiOrderbook)
        return try await _orderbook(symbol, path: "rpiDepth", limit: 1000)
    }

    private func _orderbook(_ symbol: String, path: String, limit: Int) async throws -> Orderbook {
        var components = URLComponents(string: host.rawValue + "/fapi/v1/\(path)")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)

        struct Holder: Decodable {
            let T: Int64  // Transaction time
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
            timestamp: TimeInterval(holder.T) / 1000.0
        )
    }
}

extension BinanceAPI {

    typealias Ticker = Cex.Ticker

    func tickers(_ cache: Bool = false) async throws -> [Ticker] {
        var tickers: [Ticker] = []
        if cache {
            do {
                tickers = try await tickersCache()
            } catch {
                print("Cache is broken, fetching from API. \(error)")
            }
        }
        if !tickers.isEmpty {
            return tickers
        }
        print("Fetching tickers from Binance API.")
        let components = URLComponents(string: host.rawValue + "/fapi/v1/ticker/24hr")
        let url = components?.url!
        cexRPMService.increment(.binance, api: .tickers)
        let data = try await self.data(url!, session: session)
        try await FileService.shared.write(data, name: "tickers_Binance.json")
        return try fetch24hrTickers(data: data)
    }

    func ticker(_ symbol: String) async throws -> Ticker {
        var components = URLComponents(string: host.rawValue + "/fapi/v1/ticker/24hr")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol)
        ]
        let url = components?.url!
        cexRPMService.increment(.binance, api: .ticker)
        let data = try await self.data(url!, session: session)
        return try fetch24hrTicker(data: data)
    }

    private func tickersCache() async throws -> [Ticker] {
        if let data = try await FileService.shared.read("tickers_Binance.json") {
            return try fetch24hrTickers(data: data)
        }
        return []
    }

    private func fetch24hrTickers(data: Data) throws -> [Ticker] {
        return try JSONDecoder().decode([TickerData].self, from: data).map { ticker in
            self.ticker(from: ticker)
        }
    }

    private func fetch24hrTicker(data: Data) throws -> Ticker {
        return ticker(from: try JSONDecoder().decode(TickerData.self, from: data))
    }

    private func ticker(from ticker: TickerData) -> Ticker {
        Ticker(
            symbol: ticker.symbol,
            turnover24h: ticker.quoteVolumeDouble,
            priceChangePercent: ticker.priceChangePercentDouble
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
