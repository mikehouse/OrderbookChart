
import SwiftUI
import UniformTypeIdentifiers

private struct NotCryptoSimbols {

    static let currencies = _currencies.map({ "\($0)USDT" })
    static let minerals = _minerals.map({ "\($0)USDT" })
    static let energy = _energy.map({ "\($0)USDT" })
    static let stocks = _stocks.map({ "\($0)USDT" })

    static let _currencies = [
        "NOK", // Norwegian Krone
    ]
    static let _minerals = [
        "XAU", // Gold
        "PAXG", // 1 fine troy ounce of a physical London Good Delivery gold bar
        "XAUT", // Tether Gold
        "XAG", // Silver
        "XPT", // Platinum
        "XPD", // Palladium
        "URNM", // Uranium
        "COPPER", // Copper
        "GDX", // Gold Miners ETF
    ]
    static let _energy = [
        "XLE", // Energy Select Sector SPDR Fund
        "NATGAS", // US Natural Gas
        "CL", // West Texas Intermediate (WTI) Crude Oil
        "BZ", // Brent Crude Oil
    ]
    static let _stocks = [
        "MU", // Micron Technology Inc
        "SNDK", // SanDisk Corporation
        "SPCX", // SpaceX
        "SOXL", // Direxion Daily Semiconductor Bull 3X Shares
        "SKHYNIX", // SK Hynix Inc.
        "MRVL", // Marvell Technology, Inc.
        "MSTR", // MicroStrategy
        "INTC", // Intel Corp
        "EWY", // iShares MSCI South Korea ETF
        "QQQ", // Invesco QQQ Trust
        "CRCL", // Circle Internet Group
        "CBRS", // Cerebras Systems Inc.
        "NVDA", //  NVIDIA Corporation
        "TSLA", // Tesla, Inc.
        "NBIS", //  Nebius Group N.V. Class A Ordinary Shares
        "WDC", // Western Digital Corporation
        "GLW", // Corning Incorporated
        "SAMSUNG",
        "AMD",
        "LITE", // Lumentum Holdings
        "ARM", // Arm Holdings plc
        "IBM",
        "AAOI", // Applied Optoelectronics, Inc.
        "GOOGL", // Alphabet Inc.
        "SPY", // S&P 500 index
        "AAPL",
        "QCOM", // QUALCOMM Incorporated
        "HOOD", // Robinhood Markets Inc.
        "RKLB", // Rocket Lab USA, Inc.
        "AVGO", // Broadcom Inc.
        "BBX", // BlackBerry Limited
        "TSM", // Taiwan Semiconductor Manufacturing Company
        "AXTI", // AXT Inc.
        "MSFT",
        "AMZN",
        "META", // Meta Platforms, Inc.
        "ORCL", // Oracle Corporation
        "DELL",
        "BABA", // Alibaba Group
        "FLNC", // Fluence Energy
        "PLTR", // Palantir Technologies Inc.
        "BE", // Bloom Energy Corporation
        "CRWV", // CoreWeave
        "COHR", // Coherent Corp.
        "AMAT", // Applied Materials
        "STXX", // Seagate Technology Holdings PLC
        "OPENAI", // Pre-IPO OpenAI
        "ASTS", // AST SpaceMobile, Inc.
        "USAR", // USA Rare Earth, Inc.
        "BMNR", // BitMine Immersion Technologies, Inc.
        "ALAB", // Astera Labs, Inc.
        "EWJ", // iShares MSCI Japan ETF
        "SMCI", // Super Micro Computer
        "UVXY", // ProShares Ultra VIX Short-Term Futures ETF
        "ANTHROPIC", // Pre-IPO Anthropic PBC
        "BX", // Blackstone Inc.
        "HPE", // Hewlett Packard Enterprise
        "CRWD", // CrowdStrike Holdings
        "IREN", // Iris Energy
        "HIMS", // Hims & Hers Health, Inc.
        "NOW", // ServiceNow
        "LRCX", // Lam Research Corporation
        "HYUNDAI",
        "CIEN", // Ciena Corporation
        "ASML",
        "EBAY",
        "LLY", // Eli Lilly and Company
        "NFLX",
        "KLAC", //  KLA Corporation
        "CSCO",
        "SONY",
        "BRKB", // Berkshire Hathaway Inc. Class B
        "ADBE", // Adobe Inc.
        "DKNG", // DraftKings Inc.
        "HD", // The Home Depot
        "NVO", // Novo Nordisk A/S
        "PAYP", // PayPay Corporation
        "CRM", // Salesforce, Inc.
        "UBER",
        "WMT", // Walmart Inc
        "JPM", // JPMorgan Chase
        "ZM", // Zoom Video Communications, Inc.
        "DIS", // Walt Disney Company
        "COST", // Costco Wholesale Corporation
        "IWM", // iShares Russell 2000 ETF
        "EWZ", // iShares MSCI Brazil ETF
        "RIVN", // Rivian Automotive
        "GME", // GameStop
        "DRAM", // Roundhill Memory ETF
        "SQQQ", // ProShares UltraPro Short
        "TQQQ", // ProShares UltraPro
        "QNTX", // Quantinuum
        "SNXX", // Tradr 2X Long SNDK Daily ETF
        "KORU", // Direxion Daily South Korea Bull 3X ETF
        "SKHY", // SK Hynix
        "SOXS", // Direxion Daily Semiconductor Bear 3X Shares (SOXS) ETF
        "RDW", // Redwire Corporation (RDW)
        "SSPC", // Leverage Shares 2X Short SPCX Daily ETF
        "SHOP", // Shopify Inc.
        "VRTXSTOCK", // Vertex Pharmaceuticals
        "BIIB", // Biogen Inc.
        "CXMT", // ChangXin Memory Technologies (CXMT)
        "PANW", // Palo Alto Networks, Inc.
        "NVDL", // GraniteShares 2x Long NVDA Daily ETF
        "MVLL", // GraniteShares 2x Long MRVL Daily ETF
        "AEHR", // Aehr Test Systems
        "PENGSTOCK", // Penguin Solutions (PENG)
        "BSP", // Bending Spoons SpA
        "GIGADEVICE", // GigaDevice Semiconductor Inc. H-shares
        "SNOW", // Snowflake Inc.
        "SOXX", // iShares Semiconductor ETF
        "XLK", // Technology Select Sector SPDR Fund
        "APPSTOCK", // AppLovin Corp
        "MINIMAX", // MiniMax Group Inc.
        "JNJ", // Johnson & Johnson
        "FWDI", // Forward Industries Inc.
        "UNITREE", // Unitree Robotics Inc.
        "GILD", // Gilead Sciences Inc.
        "AMGN", // Amgen Inc.
        "BAC", // Bank of America Corp
        "IONQ", // IonQ Inc.
        "CRDO", // Credo Technology Group Holding Ltd
        "INTW", // GraniteShares 2x Long INTC Daily ETF
        "ZHIPU", // Zhipu AI.
        "KSTR", // KraneShares SSE STAR Market 50 Index ETF
        "RDDT", // Reddit, Inc.
        "TSEM", // Tower Semiconductor Ltd.
        "XOM", // Exxon Mobil Corporation
        "REGN", // Regeneron Pharmaceuticals Inc.
        "UNH", // UnitedHealth Group Inc.
        "APLD", // Applied Digital Corporation
        "MARA", // MARA Holdings Inc.
        "SHAZ", // SharonAI Holdings Inc.
        "TSLL", // Direxion Daily TSLA Bull 2X ETF
        "TER", //  Teradyne, Inc.
        "ONDS", // Ondas Inc.
        "POPMART", // Pop Mart International Group
        "XLF", // Financial Select Sector SPDR Fund
        "GEV", // GE Vernova Inc.
        "GS", // Goldman Sachs Group Inc.
        "VRT", // Vertiv Holdings Co
        "TXN", // Texas Instruments
        "XBI", // SPDR S&P Biotech ETF
        "TTWO", // Take-Two Interactive Software Inc.
        "CATSTOCK", // Caterpillar Inc.
        "TENCENT", // Tencent Holdings Limited
        "WENSTOCK", // Wendy
        "PEP", // PepsiCo Inc.
        "ARKK", // Ark Innovation ETF
        "AAL", // American Airlines Group Inc.
        "TMF", // Direxion Daily 20+ Year Treasury Bull 3X ETF
        "MA", // Mastercard Inc.
        "TZA", // Direxion Daily Small Cap Bear 3X ETF
        "PYPL", // PayPal Holdings Inc.
        "V", // Visa Inc
        "TBT", // ProShares UltraShort 20+ Year Treasury
        "BITO", // ProShares Bitcoin ETF
    ]
}

struct SidebarContentView: View {

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

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var allTickers: [Ticker] = []
    @State private var tickers: [Ticker] = []
    @State private var selectedMarket = Cex.Market.futures
    @State private var customTickerSections: [TickerSection] = []
    @State private var newSectionName = ""
    @State private var tickerSortRule: TickerSortRule = .turnover
    @State private var showsCryptoTickers = true
    @State private var showsStockTickers = false
    @State private var showsCurrencyTickers = false
    @State private var showsMineralTickers = false
    @State private var showsEnergyTickers = false
    @State private var exportFormat: ExportFormat = .tradingView
    @State private var splitCount: Int = 100
    @State private var exportMessage: String?
    @State private var isSelectingExportDirectory = false
    @State private var exportingSection: TickerSection?
    @State private var rateLimitPercent: Int = 0
    @State private var hasLoadedInitialState = false
    @State private var atrPercentByTickerID: [Ticker.ID: Double] = [:]
    @State private var atrProgress: ATRProgress?
    @State private var atrRequestID: UUID?
    @State private var atrLoadingTask: Task<Void, Never>?
    @State private var tickerLoadRequestID: UUID?

    var body: some View {
        Group {
            if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                    Button("Retry") {
                        Task {
                            await loadForCurrentCex(cache: false)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if isLoading {
                if let atrProgress {
                    ProgressView(
                        value: Double(atrProgress.completed),
                        total: Double(atrProgress.total)
                    ) {
                        Text("\(atrProgress.completed)/\(atrProgress.total)")
                    }
                    .progressViewStyle(.linear)
                    .padding()
                } else {
                    ProgressView("Loading tickers…")
                }
            } else if allTickers.isEmpty {
                Text("No tickers available")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tickers: \(tickers.count)")
                        Spacer()
                        Picker("", selection: $selectedMarket) {
                            ForEach(Cex.Market.allCases) { market in
                                Text(market.title).tag(market)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .fixedSize()
                        Button(action: {
                            Task {
                                await loadForCurrentCex(cache: false)
                            }
                        }, label: {
                            Image(systemName: "arrow.counterclockwise")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                    tickerCategoryFilters
                    HStack {
                        Text("Sort by")
                        Spacer()
                        Picker("", selection: $tickerSortRule) {
                            ForEach(TickerSortRule.allCases, id: \.self) { rule in
                                Text(rule.title).tag(rule)
                            }
                        }
                        .pickerStyle(.menu)
                        .fixedSize()
                    }
                    HStack {
                        Text("API rate limits: (\(rateLimitPercent)%)")
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Button("Export") {
                            exportingSection = nil
                            isSelectingExportDirectory = true
                        }
                        .buttonStyle(.borderedProminent)
                        .fixedSize()
                    }
                    HStack(spacing: 8) {
                        Picker("", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.title).tag(format)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .fixedSize()

                        if exportFormat == .tradingView {
                            Picker("", selection: $splitCount) {
                                ForEach([100, 150, 200, 250, 300], id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .fixedSize()
                        }
                    }
                    if let exportMessage {
                        Text(exportMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                VStack {
                    ForEach(Array(appContext.recordingsService.recordings.keys)) { ticker in
                        HStack {
                            Text("\(ticker.symbol)")
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                        }
                    }
                }
                HStack(spacing: 8) {
                    TextField("Section name", text: $newSectionName)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1)
                    Button(action: addTickerSection) {
                        Label("Add section", systemImage: "plus")
                    }
                    .disabled(trimmedNewSectionName.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                List(selection: $selectedTicker) {
                    ForEach(customTickerSections) { section in
                        Section {
                            customSectionContent(section)
                        } header: {
                            customSectionHeader(section)
                        }
                    }
                    Section("Symbols") {
                        ForEach(tickers, id: \.symbol) { ticker in
                            mainTickerRow(ticker)
                                .tag(ticker)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -8)
            }
        }
        .task {
            loadCustomTickerSections()
            loadTickerCategoryFilters()
            loadSelectedMarket()
            await loadForCurrentCex(cache: true)
            hasLoadedInitialState = true
        }
        .onChange(of: selectedCex) {
            cancelATRLoading()
            Task {
                await loadForCurrentCex(cache: true)
            }
        }
        .onChange(of: selectedMarket) {
            storeSelectedMarket()
            selectedTicker = nil
            guard hasLoadedInitialState else {
                return
            }

            cancelATRLoading()
            Task {
                await loadForCurrentCex(cache: true)
            }
        }
        .onChange(of: exportMessage) {
            if let exportMessage = exportMessage {
                print(exportMessage)
            }
        }
        .onChange(of: customTickerSections) {
            storeCustomTickerSections()
        }
        .onChange(of: tickerSortRule) {
            tickerSortRuleDidChange()
        }
        .onChange(of: timeframe) {
            if tickerSortRule.sortsByATR, tickerLoadRequestID == nil {
                startATRSorting()
            }
        }
        .onChange(of: showsCryptoTickers) {
            tickerCategoryFilterDidChange()
        }
        .onChange(of: showsStockTickers) {
            tickerCategoryFilterDidChange()
        }
        .onChange(of: showsCurrencyTickers) {
            tickerCategoryFilterDidChange()
        }
        .onChange(of: showsMineralTickers) {
            tickerCategoryFilterDidChange()
        }
        .onChange(of: showsEnergyTickers) {
            tickerCategoryFilterDidChange()
        }
        .onChange(of: appContext.cexRPMService.usageByCex) { _, new in
            if let selectedCex = selectedCex {
                let rateLimit = appContext.cexRPMService.status(selectedCex)
                rateLimitPercent = rateLimit.limit > 0 ? Int((Double(rateLimit.count) / Double(rateLimit.limit)) * 100) : 0
            }
        }
        .fileImporter(
            isPresented: $isSelectingExportDirectory,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            handleExportDirectorySelection(result)
        }
        .onDisappear {
            cancelATRLoading()
        }
    }

    private var trimmedNewSectionName: String {
        newSectionName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func handleExportDirectorySelection(_ result: Result<[URL], any Error>) {
        defer {
            exportingSection = nil
        }

        switch result {
        case .success(let urls):
            guard let directoryURL = urls.first else {
                exportMessage = "Export canceled."
                return
            }
            if let exportingSection {
                exportTickers(
                    tickers(in: exportingSection),
                    to: directoryURL,
                    fileNamePrefix: exportingSection.name
                )
            } else {
                exportTickers(tickersForMainExport(), to: directoryURL)
            }
        case .failure(let error):
            exportMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    private var tickerCategoryFilters: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Toggle("Crypto", isOn: $showsCryptoTickers)
                Toggle("Stocks", isOn: $showsStockTickers)
                Toggle("Energy", isOn: $showsEnergyTickers)
            }
            HStack {
                Toggle("Currencies", isOn: $showsCurrencyTickers)
                Toggle("Minerals", isOn: $showsMineralTickers)
            }
        }
        .toggleStyle(.checkbox)
        .padding(.bottom, 4)
    }

    private func addTickerSection() {
        let name = trimmedNewSectionName
        guard !name.isEmpty else { return }

        customTickerSections.append(TickerSection(name: name))
        newSectionName = ""
    }

    private func deleteTickerSection(_ section: TickerSection) {
        customTickerSections.removeAll { $0.id == section.id }
    }

    private func loadCustomTickerSections() {
        guard let data = appContext.userDefaults.data(forKey: StorageKeys.customTickerSections.rawValue) else {
            return
        }

        do {
            customTickerSections = try JSONDecoder().decode([TickerSection].self, from: data)
        } catch {
            print("Failed to load ticker sections: \(error)")
        }
    }

    private func storeCustomTickerSections() {
        do {
            let data = try JSONEncoder().encode(customTickerSections)
            appContext.userDefaults.set(data, forKey: StorageKeys.customTickerSections.rawValue)
        } catch {
            print("Failed to store ticker sections: \(error)")
        }
    }

    private func loadTickerCategoryFilters() {
        showsCryptoTickers = storedBool(for: .showsCryptoTickers, defaultValue: true)
        showsStockTickers = storedBool(for: .showsStockTickers, defaultValue: false)
        showsCurrencyTickers = storedBool(for: .showsCurrencyTickers, defaultValue: false)
        showsMineralTickers = storedBool(for: .showsMineralTickers, defaultValue: false)
        showsEnergyTickers = storedBool(for: .showsEnergyTickers, defaultValue: false)
        applyTickerCategoryFilters()
    }

    private func storedBool(for key: StorageKeys, defaultValue: Bool) -> Bool {
        guard appContext.userDefaults.object(forKey: key.rawValue) != nil else {
            return defaultValue
        }

        return appContext.userDefaults.bool(forKey: key.rawValue)
    }

    private func loadSelectedMarket() {
        guard let rawValue = appContext.userDefaults.string(forKey: StorageKeys.selectedMarket.rawValue),
              let market = Cex.Market(rawValue: rawValue)
        else {
            return
        }

        selectedMarket = market
    }

    private func storeSelectedMarket() {
        appContext.userDefaults.set(selectedMarket.rawValue, forKey: StorageKeys.selectedMarket.rawValue)
    }

    private func storeTickerCategoryFilters() {
        appContext.userDefaults.set(showsCryptoTickers, forKey: StorageKeys.showsCryptoTickers.rawValue)
        appContext.userDefaults.set(showsStockTickers, forKey: StorageKeys.showsStockTickers.rawValue)
        appContext.userDefaults.set(showsCurrencyTickers, forKey: StorageKeys.showsCurrencyTickers.rawValue)
        appContext.userDefaults.set(showsMineralTickers, forKey: StorageKeys.showsMineralTickers.rawValue)
        appContext.userDefaults.set(showsEnergyTickers, forKey: StorageKeys.showsEnergyTickers.rawValue)
    }

    private func tickerCategoryFilterDidChange() {
        storeTickerCategoryFilters()
        applyTickerCategoryFilters()
    }

    private func tickerSortRuleDidChange() {
        if tickerSortRule.sortsByATR {
            startATRSorting()
        } else {
            cancelATRLoading()
            atrPercentByTickerID = [:]
            isLoading = false
            applyTickerCategoryFilters()
        }
    }

    private func startATRSorting() {
        cancelATRLoading()
        atrPercentByTickerID = [:]

        guard let selectedCex,
              let minimumTurnover24h = tickerSortRule.atrMinimumTurnover24h
        else {
            isLoading = false
            applyTickerCategoryFilters()
            return
        }

        let candidateTickers = allTickers.filter { $0.turnover24h > minimumTurnover24h }
        guard !candidateTickers.isEmpty else {
            tickers = []
            isLoading = false
            return
        }

        let api: ApiInterface
        switch selectedCex {
        case .bybit:
            api = appContext.bybit
        case .binance:
            api = appContext.binance
        }

        let requestID = UUID()
        atrRequestID = requestID
        atrProgress = ATRProgress(completed: 0, total: candidateTickers.count)
        isLoading = true

        let interval = timeframe
        atrLoadingTask = Task {
            await loadATRValues(
                for: candidateTickers,
                api: api,
                interval: interval,
                requestID: requestID
            )
        }
    }

    private func loadATRValues(
        for candidateTickers: [Ticker],
        api: ApiInterface,
        interval: Cex.Interval,
        requestID: UUID
    ) async {
        defer {
            if atrRequestID == requestID {
                atrProgress = nil
                atrRequestID = nil
                atrLoadingTask = nil
                isLoading = false
            }
        }

        var atrValues: [Ticker.ID: Double] = [:]

        for (index, ticker) in candidateTickers.enumerated() {
            guard atrRequestID == requestID, !Task.isCancelled else { return }

            do {
                let candles = try await api.kLines(
                    ticker.symbol,
                    market: ticker.market,
                    interval: interval,
                    limit: ATRCalculator.requestedCandleCount
                )
                guard atrRequestID == requestID, !Task.isCancelled else { return }

                if let atrPercent = ATRCalculator.normalizedPercent(for: candles) {
                    atrValues[ticker.id] = atrPercent
                }
            } catch {
                guard atrRequestID == requestID, !Task.isCancelled else { return }
                print("Failed to calculate ATR for \(ticker.symbol): \(error)")
            }

            atrProgress = ATRProgress(completed: index + 1, total: candidateTickers.count)
        }

        guard atrRequestID == requestID, !Task.isCancelled else { return }
        atrPercentByTickerID = atrValues
        applyTickerCategoryFilters()
    }

    private func cancelATRLoading() {
        atrLoadingTask?.cancel()
        atrLoadingTask = nil
        atrRequestID = nil
        atrProgress = nil
    }

    private func applyTickerCategoryFilters() {
        tickers = sortedTickers(
            allTickers
                .filter(shouldShowTicker)
                .filter(shouldShowTickerForCurrentSortRule)
        )
    }

    private func shouldShowTicker(_ ticker: Ticker) -> Bool {
        switch tickerCategory(for: ticker.symbol) {
        case .crypto:
            return showsCryptoTickers
        case .stocks:
            return showsStockTickers
        case .currencies:
            return showsCurrencyTickers
        case .minerals:
            return showsMineralTickers
        case .energy:
            return showsEnergyTickers
        }
    }

    private func shouldShowTickerForCurrentSortRule(_ ticker: Ticker) -> Bool {
        guard let turnoverRange24h = tickerSortRule.turnoverRange24h else {
            return true
        }

        if let minimum = turnoverRange24h.minimum, ticker.turnover24h <= minimum {
            return false
        }

        if let maximum = turnoverRange24h.maximum, ticker.turnover24h >= maximum {
            return false
        }

        return true
    }

    private func tickerCategory(for symbol: String) -> TickerCategory {
        if NotCryptoSimbols.stocks.contains(where: { symbol.hasPrefix($0) }) {
            return .stocks
        }
        if NotCryptoSimbols.currencies.contains(where: { symbol.hasPrefix($0) }) {
            return .currencies
        }
        if NotCryptoSimbols.minerals.contains(where: { symbol.hasPrefix($0) }) {
            return .minerals
        }
        if NotCryptoSimbols.energy.contains(where: { symbol.hasPrefix($0) }) {
            return .energy
        }
        return .crypto
    }

    @ViewBuilder
    private func customSectionContent(_ section: TickerSection) -> some View {
        let sectionTickers = tickers(in: section)
        if sectionTickers.isEmpty {
            Text("No symbols")
                .foregroundStyle(.secondary)
        } else {
            ForEach(sectionTickers, id: \.symbol) { ticker in
                tickerRow(ticker)
                    .contextMenu {
                        Button(role: .destructive) {
                            remove(ticker, from: section)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .tag(ticker)
            }
        }
    }

    private func includesInMainExportBinding(for section: TickerSection) -> Binding<Bool> {
        Binding {
            customTickerSections.first(where: { $0.id == section.id })?.includesInMainExport ?? false
        } set: { includesInMainExport in
            guard let index = customTickerSections.firstIndex(where: { $0.id == section.id }) else {
                return
            }

            customTickerSections[index].includesInMainExport = includesInMainExport
        }
    }

    @ViewBuilder
    private func mainTickerRow(_ ticker: Ticker) -> some View {
        if customTickerSections.isEmpty {
            tickerRow(ticker)
        } else {
            tickerRow(ticker)
                .contextMenu {
                    ForEach(customTickerSections) { section in
                        Button("Add to \(section.name)") {
                            add(ticker, to: section)
                        }
                        .disabled(section.symbols.contains(ticker.symbol))
                    }
                }
        }
    }

    private func add(_ ticker: Ticker, to section: TickerSection) {
        guard let index = customTickerSections.firstIndex(where: { $0.id == section.id }),
              !customTickerSections[index].symbols.contains(ticker.symbol)
        else {
            return
        }

        customTickerSections[index].symbols.append(ticker.symbol)
    }

    private func remove(_ ticker: Ticker, from section: TickerSection) {
        guard let index = customTickerSections.firstIndex(where: { $0.id == section.id }) else {
            return
        }

        customTickerSections[index].symbols.removeAll { $0 == ticker.symbol }
    }

    private func tickers(in section: TickerSection) -> [Ticker] {
        let tickerBySymbol = Dictionary(uniqueKeysWithValues: allTickers.map { ($0.symbol, $0) })
        return section.symbols.compactMap { tickerBySymbol[$0] }
    }

    private func tickersForMainExport() -> [Ticker] {
        let excludedSymbols = Set(customTickerSections
            .filter { !$0.includesInMainExport }
            .flatMap(\.symbols))

        guard !excludedSymbols.isEmpty else {
            return tickers
        }

        return tickers.filter { !excludedSymbols.contains($0.symbol) }
    }

    private func tickerRow(_ ticker: Ticker) -> some View {
        HStack {
            Text(ticker.symbol)
            Spacer()
            if ticker.priceChangePercent < 0 {
                HStack {
                    Image(systemName: "arrowtriangle.down.fill")
                    Text(ticker.priceChangePercent, format: .number.precision(.fractionLength(2)))
                    Text("%")
                }
                .foregroundColor(.red)
            } else if ticker.priceChangePercent > 0 {
                HStack {
                    Image(systemName: "arrowtriangle.up.fill")
                    Text(ticker.priceChangePercent, format: .number.precision(.fractionLength(2)))
                    Text("%")
                }
                .foregroundColor(.green)
            } else {
                Text("0.00 %")
                    .foregroundColor(.gray)
            }
        }
    }

    private func customSectionHeader(_ section: TickerSection) -> some View {
        HStack {
            Text(section.name)
            Spacer()
            Toggle("export", isOn: includesInMainExportBinding(for: section))
                .toggleStyle(.checkbox)
            Button {
                exportingSection = section
                isSelectingExportDirectory = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.borderless)
            .help("Export section")
            .disabled(tickers(in: section).isEmpty)
            Button(role: .destructive) {
                deleteTickerSection(section)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Delete section")
        }
    }

    private func loadForCurrentCex(cache: Bool) async {
        cancelATRLoading()
        atrPercentByTickerID = [:]

        let requestID = UUID()
        tickerLoadRequestID = requestID

        guard let cex = selectedCex else {
            allTickers = []
            tickers = []
            selectedTicker = nil
            errorMessage = nil
            tickerLoadRequestID = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        let market = selectedMarket

        do {
            let fetchedTickers: [Ticker]
            switch cex {
            case .bybit:
                let ticker = try await appContext.bybit.tickers(market, cache: cache)
                fetchedTickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.hasSuffix("PERP") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USD") })
                    .filter({ $0.symbol.hasSuffix("USDT") })
            case .binance:
                let ticker = try await appContext.binance.tickers(market, cache: cache)
                fetchedTickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.contains("_") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .filter({ $0.symbol.hasSuffix("USDT") })
                    .filter({ !$0.symbol.hasPrefix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USD1") })
                    .filter({ !$0.symbol.hasPrefix("BTCUSD1") })
                    .filter({ !$0.symbol.hasPrefix("ETHBTC") })
            }

            guard tickerLoadRequestID == requestID,
                  selectedCex == cex,
                  selectedMarket == market
            else {
                return
            }

            allTickers = fetchedTickers
            tickerLoadRequestID = nil

            if tickerSortRule.sortsByATR {
                startATRSorting()
            } else {
                applyTickerCategoryFilters()
                isLoading = false
            }
        } catch {
            guard tickerLoadRequestID == requestID else { return }
            tickerLoadRequestID = nil
            errorMessage = "\(error)"
            isLoading = false
        }
    }

    private func sortedTickers(_ tickers: [Ticker]) -> [Ticker] {
        func sort(by value: (Ticker) -> Double) -> [Ticker] {
            tickers.sorted { lhs, rhs in
                let lhsValue = value(lhs)
                let rhsValue = value(rhs)
                if lhsValue == rhsValue {
                    return lhs.symbol < rhs.symbol
                }
                return lhsValue > rhsValue
            }
        }

        switch tickerSortRule {
        case .turnover,
             .turnoverUnder1M,
             .turnoverOver1M,
             .turnoverOver5M,
             .turnoverOver10M,
             .turnover1MTo5M,
             .turnover1MTo10M,
             .turnover5MTo10M:
            return sort { $0.turnover24h }
        case .priceChange:
            return sort { $0.priceChangePercent }
        case .priceChangeM:
            return sort { abs($0.priceChangePercent) }
        case .atrOver1MTurnover,
             .atrOver5MTurnover,
             .atrOver10MTurnover:
            return tickers
                .compactMap { ticker -> (ticker: Ticker, atrPercent: Double)? in
                    guard let atrPercent = atrPercentByTickerID[ticker.id] else {
                        return nil
                    }
                    return (ticker, atrPercent)
                }
                .sorted { lhs, rhs in
                    if lhs.atrPercent == rhs.atrPercent {
                        return lhs.ticker.symbol < rhs.ticker.symbol
                    }
                    return lhs.atrPercent > rhs.atrPercent
                }
                .map(\.ticker)
        }
    }

    private func exportTickers(
        _ tickersToExport: [Ticker],
        to directoryURL: URL,
        fileNamePrefix: String? = nil
    ) {
        guard let selectedCex else {
            exportMessage = "Select an exchange first."
            return
        }

        let hasAccess = directoryURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                directoryURL.stopAccessingSecurityScopedResource()
            }
        }

        switch exportFormat {
        case .tradingView:
            do {
                let chunks = tickersToExport.chunked(by: splitCount)
                let timestamp = Self.exportDateFormatter.string(from: Date())
                let cexName = selectedCex.displayName
                let cexNameUppercased = cexName.uppercased()
                let fileNamePrefix = safeFileNamePrefix(fileNamePrefix)

                for (index, chunk) in chunks.enumerated() {
                    let symbols = chunk.map { ticker in
                        let marketSuffix = ticker.market == .futures ? ".P" : ""
                        return "\(cexNameUppercased):\(ticker.symbol)\(marketSuffix)"
                    }.joined(separator: ",")
                    let fileName = "\(fileNamePrefix)\(cexName)-\(selectedMarket.title)-\(chunk.count)-\(timestamp)-\(index + 1).txt"
                    let fileURL = directoryURL.appendingPathComponent(fileName)
                    guard let data = symbols.data(using: .utf8) else {
                        throw CocoaError(.fileWriteUnknown)
                    }
                    try data.write(to: fileURL)
                }

                exportMessage = "Exported \(chunks.count) file(s) to \(directoryURL.path)."
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
            }
        }
    }

    private func safeFileNamePrefix(_ prefix: String?) -> String {
        guard let prefix else { return "" }

        let safePrefix = prefix
            .components(separatedBy: Self.fileNameUnsafeCharacters)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return safePrefix.isEmpty ? "" : "\(safePrefix)-"
    }

    private struct TickerSection: Identifiable, Hashable, Codable {
        let id: UUID
        let name: String
        var symbols: [String] = []
        var includesInMainExport = false

        init(
            id: UUID = UUID(),
            name: String,
            symbols: [String] = [],
            includesInMainExport: Bool = false
        ) {
            self.id = id
            self.name = name
            self.symbols = symbols
            self.includesInMainExport = includesInMainExport
        }
    }

    private struct ATRProgress {
        let completed: Int
        let total: Int
    }

    private enum StorageKeys: String {
        case customTickerSections
        case showsCryptoTickers
        case showsStockTickers
        case showsCurrencyTickers
        case showsMineralTickers
        case showsEnergyTickers
        case selectedMarket
    }

    private enum TickerCategory {
        case crypto
        case stocks
        case currencies
        case minerals
        case energy
    }

    private enum ExportFormat: CaseIterable {
        case tradingView

        var title: String {
            switch self {
            case .tradingView:
                return "TradingView"
            }
        }
    }

    private enum TickerSortRule: CaseIterable {
        case turnover
        case turnoverUnder1M
        case turnoverOver1M
        case turnoverOver5M
        case turnoverOver10M
        case turnover1MTo5M
        case turnover1MTo10M
        case turnover5MTo10M
        case atrOver1MTurnover
        case atrOver5MTurnover
        case atrOver10MTurnover
        case priceChange
        case priceChangeM

        var title: String {
            switch self {
            case .turnover:
                return "Turnover 24H"
            case .turnoverUnder1M:
                return "Turnover < 1 M $"
            case .turnoverOver1M:
                return "Turnover > 1 M $"
            case .turnoverOver5M:
                return "Turnover > 5 M $"
            case .turnoverOver10M:
                return "Turnover > 10 M $"
            case .turnover1MTo5M:
                return "Turnover 1 M $ - 5 M $"
            case .turnover1MTo10M:
                return "Turnover 1 M $ - 10 M $"
            case .turnover5MTo10M:
                return "Turnover 5 M $ - 10 M $"
            case .atrOver1MTurnover:
                return "ATR (%) > 1 M $ Turnover"
            case .atrOver5MTurnover:
                return "ATR (%) > 5 M $ Turnover"
            case .atrOver10MTurnover:
                return "ATR (%) > 10 M $ Turnover"
            case .priceChange:
                return "Price Change 24H"
            case .priceChangeM:
                return "Price Change 24H (Abs)"
            }
        }

        var turnoverRange24h: (minimum: Double?, maximum: Double?)? {
            switch self {
            case .turnoverUnder1M:
                return (nil, 1_000_000)
            case .turnoverOver1M:
                return (1_000_000, nil)
            case .turnoverOver5M:
                return (5_000_000, nil)
            case .turnoverOver10M:
                return (10_000_000, nil)
            case .atrOver1MTurnover:
                return (1_000_000, nil)
            case .atrOver5MTurnover:
                return (5_000_000, nil)
            case .atrOver10MTurnover:
                return (10_000_000, nil)
            case .turnover1MTo5M:
                return (1_000_000, 5_000_000)
            case .turnover1MTo10M:
                return (1_000_000, 10_000_000)
            case .turnover5MTo10M:
                return (5_000_000, 10_000_000)
            case .turnover, .priceChange, .priceChangeM:
                return nil
            }
        }

        var atrMinimumTurnover24h: Double? {
            switch self {
            case .atrOver1MTurnover:
                return 1_000_000
            case .atrOver5MTurnover:
                return 5_000_000
            case .atrOver10MTurnover:
                return 10_000_000
            default:
                return nil
            }
        }

        var sortsByATR: Bool {
            atrMinimumTurnover24h != nil
        }
    }

    private static let exportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return formatter
    }()

    private static let fileNameUnsafeCharacters = CharacterSet(charactersIn: "/:")
}

private extension Array {
    func chunked(by size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
