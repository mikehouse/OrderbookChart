
import Foundation

final class CexRPMService {

    enum Api: Sendable {
        case kLines(limit: Int)
        case orderbook
        case rpiOrderbook
        case ticker
        case tickers
        case exchangeInfo

        func weight(for cex: Cex, market: Cex.Market) -> Int {
            switch cex {
            case .binance:
                return binanceWeight(for: market)
            case .bybit:
                return 0
            }
        }

        private func binanceWeight(for market: Cex.Market) -> Int {
            switch self {
            case .kLines(let limit):
                if market == .spot {
                    return 2
                }
                switch limit {
                case ..<100:
                    return 1
                case 100..<500:
                    return 2
                case 500...1000:
                    return 5
                default:
                    return 10
                }
            case .orderbook:
                switch market {
                case .futures:
                    return 20
                case .spot:
                    return 50
                }
            case .rpiOrderbook:
                switch market {
                case .futures:
                    return 20
                case .spot:
                    return 0
                }
            case .ticker:
                switch market {
                case .futures:
                    return 1
                case .spot:
                    return 2
                }
            case .tickers:
                switch market {
                case .futures:
                    return 40
                case .spot:
                    return 80
                }
            case .exchangeInfo:
                switch market {
                case .futures:
                    return 1
                case .spot:
                    return 0
                }
            }
        }
    }

    struct Usage: Equatable {
        var count: Int
        var firstIncrementAt: Date
    }

    private static let windowDuration: TimeInterval = 60
    private static let binanceLimit = 2400
    private(set) var usageByCex: [Cex: Usage] = [:]

    init() {}

    @discardableResult
    func increment(_ cex: Cex, market: Cex.Market = .futures, api: Api) -> Bool {
        increment(cex, api: api.weight(for: cex, market: market))
    }

    @discardableResult
    func increment(_ cex: Cex, api weight: Int) -> Bool {
        guard weight >= 0 else {
            return false
        }
        let requestWeight = cex == .bybit ? 0 : weight
        let limit = Self.limit(for: cex)
        let now = Date()

        guard var usage = activeUsage(for: cex, now: now) else {
            if requestWeight > limit {
                return false
            }
            usageByCex[cex] = Usage(count: requestWeight, firstIncrementAt: now)
            return true
        }

        if requestWeight > limit - usage.count {
            return false
        }

        usage.count += requestWeight
        usageByCex[cex] = usage
        return true
    }

    func hasNext(_ cex: Cex) -> Bool {
        let limit = Self.limit(for: cex)
        let count = activeUsage(for: cex, now: Date())?.count ?? 0
        return count < limit
    }

    func status(_ cex: Cex) -> (count: Int, limit: Int) {
        let limit = Self.limit(for: cex)
        let count = activeUsage(for: cex, now: Date())?.count ?? 0
        return (count, limit)
    }

    static func limit(for cex: Cex) -> Int {
        switch cex {
        case .binance:
            return binanceLimit
        case .bybit:
            return 9_999_999
        }
    }

    private func activeUsage(for cex: Cex, now: Date) -> Usage? {
        guard let usage = usageByCex[cex] else {
            return nil
        }

        if now.timeIntervalSince(usage.firstIncrementAt) >= Self.windowDuration {
            usageByCex[cex] = nil
            return nil
        }

        return usage
    }
}
