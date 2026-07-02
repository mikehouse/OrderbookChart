
import Foundation
import SwiftUI

protocol ApiInterface: Sendable {

    @concurrent
    func kLines(_ symbol: String, market: Cex.Market, interval: Cex.Interval, limit: Int) async throws -> [Candle]
    @concurrent
    func orderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook
    @concurrent
    func rpiOrderbook(_ symbol: String, market: Cex.Market) async throws -> Orderbook?
    @concurrent
    func tickers(_ market: Cex.Market, cache: Bool) async throws -> [Ticker]
    @concurrent
    func ticker(_ symbol: String, market: Cex.Market) async throws -> Ticker
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

    enum Market: String, Sendable, Hashable, CaseIterable, Identifiable {
        case futures
        case spot

        var id: String {
            return rawValue
        }

        var title: String {
            switch self {
            case .futures:
                return "Futures"
            case .spot:
                return "Spot"
            }
        }

        var bybitCategory: String {
            switch self {
            case .futures:
                return "linear"
            case .spot:
                return "spot"
            }
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
        case min60 = "1 h"
        case min240 = "4 h"
        case day1 = "1 d"

        var bybit: BybitAPI.Interval {
            switch self {
            case .min1: return .min1
            case .min3: return .min3
            case .min5: return .min5
            case .min15: return .min15
            case .min30: return .min30
            case .min60: return .min60
            case .min240: return .min240
            case .day1: return .day1
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
            case .min240: return .min240
            case .day1: return .day1
            }
        }
    }
}

extension Cex {

    struct Ticker: Sendable, Hashable, Identifiable {
        let symbol: String
        let turnover24h: Double
        let priceChangePercent: Double
        let market: Cex.Market

        var id: String {
            return "\(market.rawValue)-\(symbol)"
        }

        init(
            symbol: String,
            turnover24h: Double,
            priceChangePercent: Double,
            market: Cex.Market = .futures
        ) {
            self.symbol = symbol
            self.turnover24h = turnover24h
            self.priceChangePercent = priceChangePercent
            self.market = market
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(symbol)
            hasher.combine(market)
        }

        static func == (lhs: Ticker, rhs: Ticker) -> Bool {
            return lhs.symbol == rhs.symbol && lhs.market == rhs.market
        }
    }
}
