
import Foundation

final class BybitAPI: ApiInterface {

    enum Host: String {
        case main = "https://api.bybit.com"
    }

    enum Interval: String, Sendable, Hashable {
        case min1 = "1"
        case min3 = "3"
        case min5 = "5"
        case min15 = "15"
        case min30 = "30"
        case min60 = "60"
        case min240 = "240"
        case day1 = "D"
    }

    var host: Host = .main
    var session: URLSession = .shared

    private struct ApiResult<Result: Decodable>: Decodable {
        let result: Result
    }
}

extension BybitAPI {

    typealias Candle = Cex.Candle

    /// limit: 1 ... 1000
    /// interval: 1, 3, 5, 15, 30, 60
    func kLines(_ symbol: String, interval: Cex.Interval, limit: Int) async throws -> [Candle] {
        try await kLines(symbol, interval: interval.bybit, limit: limit)
    }

    func kLines(_ symbol: String, interval: Interval, limit: Int) async throws -> [Candle] {
        var components = URLComponents(string: host.rawValue + "/v5/market/kline")
        components?.queryItems = [
            URLQueryItem(name: "category", value: "linear"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: interval.rawValue),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)

        struct Holder: Decodable {
            let list: [[String]]
        }

        let holder = try JSONDecoder().decode(ApiResult<Holder>.self, from: data)
        return holder.result.list.map { arr -> Candle in
            Candle(
                startTime: TimeInterval(arr[0])! / 1000.0,
                open: Double(arr[1])!,
                high: Double(arr[2])!,
                low: Double(arr[3])!,
                close: Double(arr[4])!,
                turnover: Double(arr[6])!
            )
        }.reversed()
    }

}

extension BybitAPI {

    typealias Orderbook = Cex.Orderbook

    /// limit: 1...500
    func orderbook(_ symbol: String) async throws -> Orderbook {
        try await _orderbook(symbol, limit: 500, path: "orderbook")
    }

    /// limit: 1...50
    func rpiOrderbook(_ symbol: String) async throws -> Orderbook {
        try await _orderbook(symbol, limit: 50, path: "rpi_orderbook")
    }

    private func _orderbook(_ symbol: String, limit: Int, path: String = "orderbook") async throws -> Orderbook {
        var components = URLComponents(string: host.rawValue + "/v5/market/\(path)")
        components?.queryItems = [
            URLQueryItem(name: "category", value: "linear"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)

        struct Holder: Decodable {
            let s: String
            let a: [[String]]
            let b: [[String]]
            let ts: TimeInterval
        }

        let holder = try JSONDecoder().decode(ApiResult<Holder>.self, from: data)
        return Orderbook(
            symbol: holder.result.s,
            bids: holder.result.b.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            asks: holder.result.a.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            timestamp: holder.result.ts / 1000.0
        )
    }
}

extension BybitAPI {

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
        print("Fetching tickers from Bybit API.")
        var components = URLComponents(string: host.rawValue + "/v5/market/tickers")
        components?.queryItems = [
            URLQueryItem(name: "category", value: "linear")
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)
        try await FileService.shared.write(data, name: "tickers_Bybit.json")
        return try self.tickers(data: data)
    }

    func ticker(_ symbol: String) async throws -> Ticker {
        var components = URLComponents(string: host.rawValue + "/v5/market/tickers")
        components?.queryItems = [
            URLQueryItem(name: "category", value: "linear"),
            URLQueryItem(name: "symbol", value: symbol)
        ]
        let url = components?.url!
        let data = try await self.data(url!, session: session)
        guard let ticker = try self.tickers(data: data).first else {
            throw ApiInterfaceError.tickerNotFound(symbol: symbol)
        }
        return ticker
    }

    private func tickersCache() async throws -> [Ticker] {
        if let data = try await FileService.shared.read("tickers_Bybit.json") {
            return try self.tickers(data: data)
        }
        return []
    }

    private func tickers(data: Data) throws -> [Ticker] {
        struct Holder: Decodable {
            let list: [Symbol]

            struct Symbol: Decodable {
                let symbol: String
                let turnover24h: String
                let price24hPcnt: String?

                var priceChangePercent: Double {
                    Double(price24hPcnt ?? "0").map { $0 * 100 } ?? 0
                }
            }
        }

        let holder = try JSONDecoder().decode(ApiResult<Holder>.self, from: data)
        return holder.result.list.map { ticker in
            Ticker(
                symbol: ticker.symbol,
                turnover24h: Double(ticker.turnover24h)!,
                priceChangePercent: ticker.priceChangePercent
            )
        }
    }

    enum ApiInterfaceError: Error, Sendable, LocalizedError {
        case tickerNotFound(symbol: String)

        var errorDescription: String? {
            switch self {
            case .tickerNotFound(let symbol):
                return "Ticker not found: \(symbol)"
            }
        }
    }
}
