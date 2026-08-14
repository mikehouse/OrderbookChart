
import SwiftUI

struct SidebarDetailsView: View {

    @Binding private var selectedCex: Cex?
    @Binding private var selectedTicker: Ticker?
    @Binding private var timeframe: Cex.Interval

    @Environment(AppContext.self) private var appContext

    init(
        selectedCex: Binding<Cex?>,
        selectedTicker: Binding<Ticker?>,
        timeframe: Binding<Cex.Interval>
    ) {
        _selectedCex = selectedCex
        _selectedTicker = selectedTicker
        _timeframe = timeframe
    }

    @State private var candles: [Candle] = []
    @State private var orderbook: Orderbook?
    @State private var rpiOrderbook: Orderbook?
    @State private var ticker: Ticker?
    @State private var launchDate: Date?

    @State private var error: String?

    @State private var candleLimit = 200
    @State private var candleLimits = [100, 150, 200, 250, 300, 400, 500]

    @State private var refreshInterval = 30
    @State private var refreshIntervals = [10, 20, 30, 40, 50, 60]
    @State private var autoRefresh = false
    @State private var autoRefreshTimer: Timer?

    @State private var candleSize = 2
    @State private var candleSizes = [2, 4]

    @State private var orderbookUnion = 10
    @State private var orderbookUnions = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]

    @State private var timeframes = Cex.Interval.allCases

    var body: some View {
        Group {
            if let error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if selectedCex != nil, selectedTicker != nil {
                GeometryReader { geometry in
                    ChartView(
                        candleSize: $candleSize,
                        orderbookUnion: $orderbookUnion,
                        candles: $candles,
                        orderbook: $orderbook,
                        rpiOrderbook: $rpiOrderbook,
                        ticker: ticker ?? selectedTicker,
                        launchDate: launchDate,
                        isSnapshot: false
                    )
                    .toolbar {
                        openSnapshotsToolbar()
                        makeChartSnapshotToolbar(height: geometry.size.height)
                        recordToolbar(height: geometry.size.height)
                        refreshIntervalToolbar()
                        fetchToolbar()
                        candlesSizeToolbar()
                        candlesLimitToolbar()
                        orderbookUnionToolbar()
                        timeframeToolbar()
                    }
                    .onChange(of: candleSize) {
                        appContext.userDefaults.set(candleSize, forKey: StorageKeys.candleSize.rawValue)
                    }
                    .onChange(of: candleLimit) {
                        appContext.userDefaults.set(candleLimit, forKey: StorageKeys.candleLimit.rawValue)
                    }
                    .onChange(of: timeframe) {
                        appContext.userDefaults.set(timeframe.rawValue, forKey: StorageKeys.timeframe.rawValue)
                    }
                    .onChange(of: orderbookUnion) {
                        appContext.userDefaults.set(orderbookUnion, forKey: StorageKeys.orderbookUnion.rawValue)
                    }
                    .onChange(of: refreshInterval) {
                        appContext.userDefaults.set(refreshInterval, forKey: StorageKeys.refreshInterval.rawValue)
                    }
                }
            } else {
                Text("Select a ticker and CEX to view details")
            }
        }
        .onChange(of: selectedCex) {
            Task { await updateChart() }
        }
        .onChange(of: autoRefresh) {
            if autoRefresh {
                autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval), repeats: true) { _ in
                    Task { @MainActor in
                        await updateChart()
                    }
                }
            } else {
                autoRefreshTimer?.invalidate()
                autoRefreshTimer = nil
            }
        }
        .onChange(of: selectedTicker) {
            Task { await updateChart() }
        }
        .task {
            let candleSize = appContext.userDefaults.integer(forKey: StorageKeys.candleSize.rawValue)
            if candleSize != 0 {
                self.candleSize = candleSize
            }
            let candleLimit = appContext.userDefaults.integer(forKey: StorageKeys.candleLimit.rawValue)
            if candleLimit != 0 {
                self.candleLimit = candleLimit
            }
            let orderbookUnion = appContext.userDefaults.integer(forKey: StorageKeys.orderbookUnion.rawValue)
            if orderbookUnion != 0 {
                self.orderbookUnion = orderbookUnion
            }
            let refreshInterval = appContext.userDefaults.integer(forKey: StorageKeys.refreshInterval.rawValue)
            if refreshInterval != 0 {
                self.refreshInterval = refreshInterval
            }
            if let timeframe = appContext.userDefaults.string(forKey: StorageKeys.timeframe.rawValue) {
                self.timeframe = .init(rawValue: timeframe)!
            }
        }
    }

    private func fetchToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button(action: {
                Task { await updateChart() }
            }) {
                Text("Fetch")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func timeframeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                Text("TF")
                    .fixedSize()
                    .padding(.leading, 15)
                Picker("", selection: $timeframe) {
                    ForEach(timeframes, id: \.self) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
            }
        }
    }

    private func orderbookUnionToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                Text("Density")
                    .fixedSize()
                    .padding(.leading, 15)
                Picker("", selection: $orderbookUnion) {
                    ForEach(orderbookUnions, id: \.self) { union in
                        Text("\(union)").tag(union)
                    }
                }
            }
        }
    }

    private func candlesLimitToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                Text("Candles")
                    .fixedSize()
                    .padding(.leading, 15)
                Picker("", selection: $candleLimit) {
                    ForEach(candleLimits, id: \.self) { limit in
                        Text("\(limit)").tag(limit)
                    }
                }
            }
        }
    }

    private func candlesSizeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                Text("Candle Size")
                    .fixedSize()
                    .padding(.leading, 15)
                Picker("", selection: $candleSize) {
                    ForEach(candleSizes, id: \.self) { size in
                        Text("\(size)").tag(size)
                    }
                }
            }
        }
    }

    private func refreshIntervalToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            HStack {
                Toggle("Auto Refresh", isOn: $autoRefresh)
                    .toggleStyle(.checkbox)
                    .padding(.leading, 12)
                Picker("", selection: $refreshInterval) {
                    ForEach(refreshIntervals, id: \.self) { interval in
                        Text("\(interval) sec").tag(interval)
                    }
                }
                .disabled(autoRefresh)
            }
        }
    }

    private func makeChartSnapshotToolbar(height: Double) -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: {
                makeSnapshot(
                    selectedTicker: selectedTicker!,
                    candleSize: candleSize,
                    orderbookUnion: orderbookUnion,
                    candles: candles,
                    orderbook: orderbook,
                    rpiOrderbook: rpiOrderbook,
                    ticker: ticker ?? selectedTicker!,
                    launchDate: launchDate,
                    height: height
                )
            }) {
                HStack {
                    Text("Snapshot")
                    Image(systemName: "square.and.arrow.down")
                        .imageScale(.medium)
                }
                .padding([.leading, .trailing], 6)
            }
            .disabled(candles.isEmpty)
        }
    }

    private func openSnapshotsToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: {
                NSWorkspace.shared.activateFileViewerSelecting([FileManager.default.temporaryDirectory])
            }) {
                HStack {
                    Image(systemName: "folder")
                        .imageScale(.medium)
                }
            }
        }
    }

    private func recordToolbar(height: Double) -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: {
                if let selectedTicker, let selectedCex {
                    if appContext.recordingsService.recording(for: selectedTicker) == nil {
                        let recordDate = Date()
                        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval), repeats: true) { [candleSize, orderbookUnion] time in
                            Task { @MainActor in
                                if let (candles, orderbook, rpiOrderbook, ticker, launchDate) = try? await chartData(
                                    selectedCex: selectedCex,
                                    selectedTicker: selectedTicker
                                ) {
                                    makeSnapshot(
                                        selectedTicker: selectedTicker,
                                        candleSize: candleSize,
                                        orderbookUnion: orderbookUnion,
                                        candles: candles,
                                        orderbook: orderbook,
                                        rpiOrderbook: rpiOrderbook,
                                        ticker: ticker ?? selectedTicker,
                                        launchDate: launchDate,
                                        height: height
                                    )
                                }
                            }
                        }
                        appContext.recordingsService.saveRecording(selectedTicker, date: (recordDate, timer))
                    } else {
                        appContext.recordingsService.removeRecording(selectedTicker)
                    }
                }
            }) {
                HStack {
                    if let selectedTicker,
                        let recordDate = appContext.recordingsService.recording(for: selectedTicker)?.0
                    {
                        Image(systemName: "record.circle.fill")
                            .foregroundColor(.red)
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            HStack {
                                let date = context.date
                                    .addingTimeInterval(-recordDate.timeIntervalSince1970)
                                    .addingTimeInterval(-TimeInterval(TimeZone.current.secondsFromGMT()))
                                Text(
                                    date.formatted(
                                        .dateTime
                                            .hour()
                                            .minute()
                                            .second()
                                    ))
                            }
                        }
                    } else {
                        Image(systemName: "record.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func updateChart() async {
        do {
            error = nil
            let (candles, orderbook, rpiOrderbook, ticker, launchDate) = try await chartData(
                selectedCex: selectedCex, selectedTicker: selectedTicker
            )
            self.candles = candles
            self.orderbook = orderbook
            self.rpiOrderbook = rpiOrderbook
            self.ticker = ticker
            self.launchDate = launchDate
        } catch {
            self.candles = []
            self.orderbook = nil
            self.rpiOrderbook = nil
            self.ticker = nil
            self.launchDate = nil
            self.error = "\(error)"
            print(error)
        }
    }

    private func chartData(selectedCex: Cex?, selectedTicker: Ticker?) async throws -> (
        candles: [Candle],
        orderbook: Orderbook?,
        rpiOrderbook: Orderbook?,
        ticker: Ticker?,
        launchDate: Date?
    ) {
        guard let selectedCex, let selectedTicker else {
            return ([], nil, nil, nil, nil)
        }
        let api: ApiInterface
        switch selectedCex {
        case .binance:
            api = appContext.binance
        case .bybit:
            api = appContext.bybit
        }
        let market = selectedTicker.market
        async let launchDate = try? api.launchDate(selectedTicker.symbol, market: market)
        let (candles, orderbook, rpiOrderbook, ticker) = try await (
            api.kLines(selectedTicker.symbol, market: market, interval: timeframe, limit: candleLimit),
            api.orderbook(selectedTicker.symbol, market: market),
            api.rpiOrderbook(selectedTicker.symbol, market: market),
            api.ticker(selectedTicker.symbol, market: market)
        )
        return (candles, orderbook, rpiOrderbook, ticker, await launchDate)
    }

    private func makeSnapshot(
        selectedTicker: Ticker,
        candleSize: Int,
        orderbookUnion: Int,
        candles: [Candle],
        orderbook: Orderbook?,
        rpiOrderbook: Orderbook?,
        ticker: Ticker?,
        launchDate: Date?,
        height: Double
    ) {
        let data = ImageService.shared.chartSnapshotPNG(
            candleSize: candleSize,
            orderbookUnion: orderbookUnion,
            candles: candles,
            orderbook: orderbook,
            rpiOrderbook: rpiOrderbook,
            ticker: ticker,
            launchDate: launchDate,
            height: height
        )
        if let data {
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent(selectedTicker.symbol)
            if !FileManager.default.fileExists(atPath: dir.path) {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            let file = dir
                .appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
                .appendingPathExtension("png")
            Task {
                try? await writeSnapshot(data: data, url: file)
            }
        }
    }

    @concurrent
    private func writeSnapshot(data: Data, url: URL) async throws {
        try data.write(to: url, options: .atomicWrite)
    }
}

private enum StorageKeys: String {
    case candleSize
    case candleLimit
    case timeframe
    case orderbookUnion
    case refreshInterval
}

#Preview {
    NavigationSplitView {
        Text("Left")
            .navigationSplitViewColumnWidth(112)
    } content: {
        Text("Center")
            .navigationSplitViewColumnWidth(64)
    } detail: {
        SidebarDetailsView(
            selectedCex: .constant(.bybit),
            selectedTicker: .constant(.init(symbol: "BTCUSDT", turnover24h: 5473206785.5191, priceChangePercent: 2.31)),
            timeframe: .constant(.min1)
        )
        .navigationSplitViewColumnWidth(460)
        .environment(
            AppContext(
                binance: MockApi.bybitBTC1Min,
                bybit: MockApi.bybitBTC1Min,
                userDefaults: UserDefaults(),
                recordingsService: RecordingsService(),
                cexRPMService: CexRPMService()
            ))
    }
    .navigationTitle("")
}
