
import Foundation
import SwiftUI

protocol ApiInterface: Sendable {

    @concurrent
    func kLines(_ symbol: String, interval: Cex.Interval, limit: Int) async throws -> [Candle]
    @concurrent
    func orderbook(_ symbol: String) async throws -> Orderbook
    @concurrent
    func rpiOrderbook(_ symbol: String) async throws -> Orderbook
    @concurrent
    func tickers(_ cache: Bool) async throws -> [Ticker]
}

extension ApiInterface {

    @concurrent
    func data(_ url: URL, session: URLSession) async throws -> Data {
        print(url)
        let (data, _) = try await session.data(from: url)
        return data
    }
}

typealias Ticker = Cex.Ticker
typealias Candle = Cex.Candle
typealias Orderbook = Cex.Orderbook

enum Cex: String, CaseIterable, Sendable, Identifiable {

    case bybit = "Bybit"
    case binance = "Binance"

    var displayName: String {
        return self.rawValue
    }

    var id: String {
        return self.rawValue
    }
    
    var logo: String {
        switch self {
        case .bybit:
            return "bybit"
        case .binance:
            return "binance"
        }
    }
}

extension Cex {

    struct Candle: Sendable {
        let startTime: TimeInterval
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let turnover: Double
    }
}

extension Cex {

    struct Orderbook: Sendable {
        struct Level: Sendable {
            let price: Double
            let size: Double
        }

        let symbol: String
        let bids: [Level]
        let asks: [Level]
        let timestamp: TimeInterval
    }
}


extension Cex {

    enum Interval: String, Sendable, Hashable, CaseIterable {

        case min1 = "1 min"
        case min3 = "3 min"
        case min5 = "5 min"
        case min15 = "15 min"
        case min30 = "30 min"
        case min60 = "60 min"

        var bybit: BybitAPI.Interval {
            switch self {
            case .min1: return .min1
            case .min3: return .min3
            case .min5: return .min5
            case .min15: return .min15
            case .min30: return .min30
            case .min60: return .min60
            }
        }

        var binance: BinanceAPI.Interval {
            switch self {
            case .min1: return .min1
            case .min3: return .min3
            case .min5: return .min5
            case .min15: return .min15
            case .min30: return .min30
            case .min60: return .min60
            }
        }
    }
}

extension Cex {

    struct Ticker: Sendable, Hashable, Identifiable {
        let symbol: String
        let turnover24h: Double

        var id: String {
            return symbol
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(symbol)
        }

        static func == (lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.symbol == rhs.symbol
        }
    }
}
