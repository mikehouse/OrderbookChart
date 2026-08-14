
import Foundation

struct MockApi: ApiInterface, Sendable {

    static let bybitBTC1Min: MockApi = MockApi(
        cex: .bybit,
        kLinesMockFileName: "bybit-kline?category=linear-symbol=BTCUSDT-interval=1-limit=100.json",
        orderbookMockFileName: "bybit-orderbook?category=linear-symbol=BTCUSDT-limit=500.json",
        rpiOrderbookMockFileName: "bybit-rpi_orderbook?category=linear-symbol=BTCUSDT-limit=50.json",
    )
    static let bybitRIVER1Min: MockApi = MockApi(
        cex: .bybit,
        kLinesMockFileName: "bybit-kline?category=linear-symbol=RIVERUSDT-interval=1-limit=100.json",
        orderbookMockFileName: "bybit-orderbook?category=linear-symbol=RIVERUSDT-limit=500.json",
        rpiOrderbookMockFileName: "bybit-rpi_orderbook?category=linear-symbol=RIVERUSDT-limit=50.json",
    )

    let cex: Cex
    let kLinesMockFileName: String
    let orderbookMockFileName: String
    let rpiOrderbookMockFileName: String

    func kLines(_ symbol: String, market: Cex.Market, interval: Cex.Interval, limit: Int) async throws -> [Candle] {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!).appendingPathComponent(kLinesMockFileName)
        let data = try Data(contentsOf: url)

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

    func orderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook {
        try await _orderbook(orderbookMockFileName)
    }

    func rpiOrderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook? {
        try await _orderbook(rpiOrderbookMockFileName)
    }

    private func _orderbook(_ filename: String) async throws -> Orderbook {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!).appendingPathComponent(filename)
        let data = try Data(contentsOf: url)

        struct Holder: Decodable {
            let s: String
            let a: [[String]]
            let b: [[String]]
            let ts: TimeInterval
        }

        let holder = try JSONDecoder().decode(ApiResult<Holder>.self, from: data)
        return Orderbook(
            symbol: holder.result.s,
            bids: holder.result.a.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            asks: holder.result.b.map {
                Orderbook.Level(price: Double($0[0])!, size: Double($0[1])!)
            },
            timestamp: holder.result.ts / 1000.0
        )
    }

    func tickers(_ market: Cex.Market, cache: Bool = false) async throws -> [Ticker] {
        return []
    }

    func ticker(_ symbol: String, market: Cex.Market) async throws -> Ticker {
        Ticker(symbol: symbol, turnover24h: 10000, priceChangePercent: 0, market: market)
    }

    func launchDate(_ symbol: String, market: Cex.Market) async throws -> Date? {
        nil
    }

    private struct ApiResult<Result: Decodable>: Decodable {
        let result: Result
    }
}
