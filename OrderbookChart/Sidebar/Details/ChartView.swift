
import Foundation
import Charts
import SwiftUI

struct ChartView: View {

    @Binding private var candleSize: Int
    @Binding private var orderbookUnion: Int
    @Binding private var candles: [Candle]
    @Binding private var orderbook: Orderbook?
    @Binding private var rpiOrderbook: Orderbook?
    private let ticker: Ticker?
    private let isSnapshot: Bool
    
    private let turnoverChartHeight: Double = 60
    private static let atrPeriod = 14
    private static let atrCandleCount = 100

    init(
        candleSize: Binding<Int>,
        orderbookUnion: Binding<Int>,
        candles: Binding<[Candle]>,
        orderbook: Binding<Orderbook?>,
        rpiOrderbook: Binding<Orderbook?>,
        ticker: Ticker?,
        isSnapshot: Bool
    ) {
        self._candleSize = candleSize
        self._orderbookUnion = orderbookUnion
        self._candles = candles
        self._orderbook = orderbook
        self._rpiOrderbook = rpiOrderbook
        self.ticker = ticker
        self.isSnapshot = isSnapshot
    }

    var body: some View {
        let (sellVolume, buyVolume, pointsSet) = orderbookPoints()
        let points = pointsSet.flatMap({ $0.points })
        let prices = points.map({ $0.y }).sorted()
        let low: Double = prices.first.map({ min(candles.map(\.low).min() ?? 0, $0) })
            ?? candles.map(\.low).min() ?? 0
        let high: Double = prices.last.map({ max(candles.map(\.high).max() ?? 0, $0) })
            ?? candles.map(\.high).max() ?? 0
        let maxYAxisLabelWidth = calculateMaxYAxisLabelWidth(for: high)
        let turnover = turnoverValues()
        let atrPercent = averageTrueRangePercent()

        container {
            VStack(spacing: 8) {
                if let ticker {
                    HStack(spacing: 4) {
                        Text("Turnover 24h:")
                            .foregroundStyle(Color.gray)
                        Text(ticker.turnover24h, format: .number.precision(.fractionLength(0...2)).grouping(.automatic))
                        Text("$")
                        Spacer()
                    }
                }
                if let atrPercent {
                    HStack(spacing: 4) {
                        Text("ATR:")
                            .foregroundStyle(Color.gray)
                        Text(atrPercent, format: .number.precision(.fractionLength(0...4)).grouping(.automatic))
                        Text("%")
                        Spacer()
                    }
                }
                HStack {
                    let buy = buyVolume * 100.0 / (sellVolume + buyVolume)
                    let sell = 100.0 - buy
                    Text("OrderBook:")
                        .foregroundStyle(Color.gray)
                    HStack(spacing: 4) {
                        Text(buyVolume, format: .number.precision(.fractionLength(0...2)).grouping(.automatic))
                        Text("(")
                        Text("$")
                        Text(buy, format: .number.precision(.fractionLength(0...2)).grouping(.automatic))
                        Text("% )")
                    }
                    .foregroundStyle(.green)
                    HStack(spacing: 4) {
                        Text(sellVolume, format: .number.precision(.fractionLength(0...2)).grouping(.automatic))
                        Text("$")
                        Text("(")
                        Text(sell, format: .number.precision(.fractionLength(0...2)).grouping(.automatic))
                        Text("% )")
                    }
                    .foregroundStyle(.red)
                    Spacer()
                }
            }
            .padding([.leading, .top])
            Chart {
                ForEach(Array(candles.enumerated()), id: \.offset) { id, kline in
                    Plot {
                        let color: Color = kline.close >= kline.open ? .green : .red
                        // Wick (low to high)
                        RuleMark(
                            x: .value("Index", id),
                            yStart: .value("Low", kline.low),
                            yEnd: .value("High", kline.high)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .foregroundStyle(color)

                        // Body (open to close)
                        RectangleMark(
                            x: .value("Id", id),
                            yStart: .value("Open/Close Start", min(kline.open, kline.close)),
                            yEnd: .value("Open/Close End", max(kline.open, kline.close)),
                            width: .fixed(Double(candleSize))
                        )
                        .foregroundStyle(color)
                    }
                }

                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    LineMark(
                        x: .value("a", point.x),
                        y: .value("b", point.y)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(point.color)
                    .foregroundStyle(by: .value("Group", point.group))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 10)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .chartYScale(domain: (low * 1)...(high * 1))
            .chartXScale(domain: 0...(max(candles.count - 1, 0)))
            .frame(width: Double(candles.count) * Double(candleSize + 2))
            .fixedSize(horizontal: true, vertical: false)
            .padding()
            .chartLegend(.hidden)

            Chart {
                ForEach(Array(turnover.enumerated()), id: \.offset) { id, value in
                    Plot {
                        RectangleMark(
                            x: .value("Id", id),
                            yStart: .value("Open/Close Start", 0),
                            yEnd: .value("Open/Close End", value),
                            width: .fixed(Double(candleSize))
                        )
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: turnoverXAxisIndexes(maxLabels: 5)) { value in
                    AxisValueLabel {
                        if let index = value.as(Int.self) {
                            Text(turnoverDateLabel(at: index))
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .padding(.leading, maxYAxisLabelWidth)
            .padding(.top, -20)
            .padding(.bottom, 16)
            .chartXScale(domain: 0...(max(candles.count - 1, 0)))
            .frame(width: Double(candles.count) * Double(candleSize + 2), height: turnoverChartHeight)
        }
    }

    @ViewBuilder
    private func container<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if isSnapshot {
            VStack(content: content)
        } else {
            ScrollView(.horizontal, content: content)
        }
    }

    // Not reliable. Investigate when have time.
    func calculateMaxYAxisLabelWidth(for value: Double) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 12)
        var fractional = 2
        if value >= 100.0 {
            fractional = 0
        } else if value < 100.0, value >= 30 {
            fractional = 1
        }
        let maxString = String(format: "%.\(fractional)f", value)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (maxString as NSString).size(withAttributes: attributes)
        return size.width + 10
    }

    private func averageTrueRangePercent() -> Double? {
        guard candles.count >= Self.atrCandleCount else { return nil }

        let sourceCandles: [Candle]
        // With no spare candle, include the current one. Otherwise use the latest 100 closed candles.
        if candles.count == Self.atrCandleCount {
            sourceCandles = candles
        } else {
            sourceCandles = Array(candles.dropLast().suffix(Self.atrCandleCount))
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

        guard trueRanges.count >= Self.atrPeriod else { return nil }

        var atr = trueRanges
            .prefix(Self.atrPeriod)
            .reduce(0, +) / Double(Self.atrPeriod)

        for trueRange in trueRanges.dropFirst(Self.atrPeriod) {
            atr = (atr * Double(Self.atrPeriod - 1) + trueRange) / Double(Self.atrPeriod)
        }

        return atr / latestClose * 100
    }

    private func turnoverValues() -> [Double] {
        guard !candles.isEmpty else { return [] }
        let turnover = candles.map(\.turnover)
        let maxTurnover = turnover.max()!
        let maxY = turnoverChartHeight
        return turnover.map { turnover in
            let max = turnover / maxTurnover * maxY
            return max
        }
    }

    private func turnoverXAxisIndexes(maxLabels: Int) -> [Int] {
        let count = candles.count
        guard count > 0 else { return [] }

        let labelCount = min(maxLabels, count)
        guard labelCount > 1 else { return [0] }

        let lastIndex = count - 1
        let lastLabelIndex = labelCount - 1

        return (0..<labelCount).map { labelIndex in
            labelIndex * lastIndex / lastLabelIndex
        }
    }

    private func turnoverDateLabel(at index: Int) -> String {
        guard candles.indices.contains(index) else { return "" }

        let date = Date(timeIntervalSince1970: candles[index].startTime)
        return date.formatted(.dateTime.day(.twoDigits).hour().minute())
    }

    private func orderbookPoints() -> (sellVolume: Double, buyVolume: Double, points: [ChartPointsSet]) {
        guard var orderbook, !orderbook.asks.isEmpty, !orderbook.bids.isEmpty else {
            return (sellVolume: 0, buyVolume: 0, points: [])
        }
        if let rpiOrderbook {
            orderbook = .init(
                symbol: orderbook.symbol,
                bids: orderbook.bids + rpiOrderbook.bids,
                asks: orderbook.asks + rpiOrderbook.asks,
                timestamp: orderbook.timestamp
            )
        }
        var sell: [(price: Double, volume: Double)] = orderbook.asks.map({
            return (price: $0.price, volume: $0.price * $0.size)
        })
        var buy: [(price: Double, volume: Double)] = orderbook.bids.map({
            return (price: $0.price, volume: $0.price * $0.size)
        })

        sell = sell.sorted(by: { $0.price > $1.price })
        buy = buy.sorted(by: { $0.price > $1.price })

        var sellUniq: [(price: Double, volume: Double)] = []
        var buyUniq: [(price: Double, volume: Double)] = []

        do {
            while true {
                if sell.isEmpty {
                    break
                }
                let temp = sell[0]
                let sellSame = sell.filter({ $0.price == temp.price })
                sell = sell.filter({ $0.price != temp.price })
                sellUniq.append((price: temp.price, volume: sellSame.map(\.volume).reduce(0, +)))
            }
            sell = sellUniq
        }
        do {
            while true {
                if buy.isEmpty {
                    break
                }
                let temp = buy[0]
                let buySame = buy.filter({ $0.price == temp.price })
                buy = buy.filter({ $0.price != temp.price })
                buyUniq.append((price: temp.price, volume: buySame.map(\.volume).reduce(0, +)))
            }
            buy = buyUniq
        }

        if orderbookUnion > 1 {
            var count = 0
            let step = 2
            while count < orderbookUnion {
                if sell.count >= step {
                    sell = sell.chunked(into: step).map { arr in
                        // Volume Weighted Average Price (VWAP)
                        let price = arr.map({ $0.price * $0.volume }).reduce(0, +)
                        let volume = arr.map(\.volume).reduce(0, +)
                        let wp = price / volume
                        return (wp, volume)
                    }
                }
                if buy.count >= step {
                    buy = buy.chunked(into: step).map { arr in
                        let price = arr.map({ $0.price * $0.volume }).reduce(0, +)
                        let volume = arr.map(\.volume).reduce(0, +)
                        let wp = price / volume
                        return (wp, volume)
                    }
                }
                count += step
            }
        }

        let currentPrice = candles.last!.close
        let candleHighestPrice = candles.map(\.high).sorted().last!
        let candleLowestPrice = candles.map(\.low).sorted().first!
        let sellVolumes = sell.map(\.volume)
        let buyVolumes = buy.map(\.volume)
        let volumes = (sellVolumes + buyVolumes).sorted()
        let sellVolume = sellVolumes.reduce(0, +)
        let buyVolume = buyVolumes.reduce(0, +)
        let lowestVolume = volumes.first!
        let highestVolume = volumes.last!
        let lowToHighVolume = highestVolume / lowestVolume
        let volumeDownscale = Double(candles.count) / lowToHighVolume

        var sellPoints: [ChartPointsSet] = []
        var buyPoints: [ChartPointsSet] = []
        for (idx, (price, volume)) in sell.enumerated() where price <= candleHighestPrice {
            let color: Color = price > currentPrice ? .red : .green
            let max = volume / lowestVolume * volumeDownscale
            let id = "\(idx)-sell"
            let set = ChartPointsSet(points: [0, max].map({ ChartPoint(x: Double($0), y: price, group: id, color: color) }))
            sellPoints.append(set)
        }
        for (idx, (price, volume)) in buy.enumerated() where price >= candleLowestPrice {
            let color: Color = price > currentPrice ? .red : .green
            let max = volume / lowestVolume * volumeDownscale
            let id = "\(idx)-buy"
            let set = ChartPointsSet(points: [0, max].map({ ChartPoint(x: Double($0), y: price, group: id, color: color) }))
            buyPoints.append(set)
        }

        var points: [ChartPointsSet] = []
        points.append(contentsOf: sellPoints)
        points.append(contentsOf: buyPoints)
        
        let currentPriceSet = ChartPointsSet(
            points: [
                0, Double(candles.count)
            ].map({
                ChartPoint(
                    x: Double($0),
                    y: currentPrice,
                    group: "current-price",
                    color: .purple
                )
            })
        )
        points.append(currentPriceSet)
        return (sellVolume: sellVolume, buyVolume: buyVolume, points: points)
    }
}

private struct ChartPoint {
    let x: Double
    let y: Double
    let group: String
    let color: Color
}

private struct ChartPointsSet {
    let points: [ChartPoint]
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    PreviewWrapper()
        .frame(width: 700, height: 400)
}

private struct PreviewWrapper: View {

    @State private var candles: [Candle] = []
    @State private var orderbook: Orderbook?
    @State private var rpiOrderbook: Orderbook?
    @State private var ticker: Ticker?

    var body: some View {
        if orderbook != nil, !candles.isEmpty {
            ChartView(
                candleSize: .constant(4),
                orderbookUnion: .constant(4),
                candles: $candles,
                orderbook: $orderbook,
                rpiOrderbook: $rpiOrderbook,
                ticker: ticker,
                isSnapshot: false
            )
        } else {
            Text("")
                .task {
                    let api = MockApi.bybitBTC1Min
                    let (candles, orderbook, rpiOrderbook, ticker) = try! await (
                        api.kLines("", market: .futures, interval: .min1, limit: 0),
                        api.orderbook("", market: .futures),
                        api.rpiOrderbook("", market: .futures),
                        api.ticker("BTCUSDT", market: .futures),
                    )
                    self.candles = candles
                    self.orderbook = orderbook
                    self.rpiOrderbook = rpiOrderbook
                    self.ticker = ticker
                }
        }
    }
}
