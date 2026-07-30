
import Foundation

enum ATRCalculator {

    static let requestedCandleCount = 101

    private static let period = 14
    private static let candleCount = 100

    static func normalizedPercent(for candles: [Candle]) -> Double? {
        guard candles.count >= candleCount else { return nil }

        let sourceCandles: [Candle]
        // With no spare candle, include the current one. Otherwise use the latest 100 closed candles.
        if candles.count == candleCount {
            sourceCandles = candles
        } else {
            sourceCandles = Array(candles.dropLast().suffix(candleCount))
        }

        guard let firstCandle = sourceCandles.first else { return nil }
        guard let latestClose = sourceCandles.last?.close, latestClose != 0 else { return nil }

        let remainingTrueRanges = zip(sourceCandles, sourceCandles.dropFirst()).map { previous, current in
            let highLowRange = current.high - current.low
            let highPreviousCloseRange = abs(current.high - previous.close)
            let lowPreviousCloseRange = abs(current.low - previous.close)
            return max(highLowRange, max(highPreviousCloseRange, lowPreviousCloseRange))
        }
        let trueRanges = [firstCandle.high - firstCandle.low] + remainingTrueRanges

        guard trueRanges.count >= period else { return nil }

        var atr = trueRanges
            .prefix(period)
            .reduce(0, +) / Double(period)

        for trueRange in trueRanges.dropFirst(period) {
            atr = (atr * Double(period - 1) + trueRange) / Double(period)
        }

        return atr / latestClose * 100
    }
}
