
import SwiftUI
import UniformTypeIdentifiers

private struct NotCryptoSimbols {

    static let currencies = [
        "NOK", // Norwegian Krone
    ]
    static let minerals = [
        "XAU", // Gold
        "PAXG", // 1 fine troy ounce of a physical London Good Delivery gold bar
        "XAUT", // Tether Gold
        "XAG", // Silver
        "XPT", // Platinum
        "XPD", // Palladium
        "URNM", // Uranium
        "COPPER", // Copper
    ]
    static let energy = [
        "XLE", // Energy Select Sector SPDR Fund
        "NATGAS", // US Natural Gas
        "CL", // West Texas Intermediate (WTI) Crude Oil
        "BZ", // Brent Crude Oil
    ]
    static let stocks = [
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
        "DRAM" // Roundhill Memory ETF
    ]
}

struct SidebarContentView: View {

    @Binding private var selectedCex: Cex?
    @Binding private var selectedTicker: Ticker?

    @Environment(AppContext.self) private var appContext

    init(
        selectedCex: Binding<Cex?>,
        selectedTicker: Binding<Ticker?>
    ) {
        _selectedCex = selectedCex
        _selectedTicker = selectedTicker
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
                ProgressView("Loading tickers…")
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
            applyTickerCategoryFilters()
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
                exportTickers(tickers, to: directoryURL)
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

    private func applyTickerCategoryFilters() {
        tickers = sortedTickers(allTickers.filter(shouldShowTicker))
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
        guard let cex = selectedCex else {
            allTickers = []
            tickers = []
            selectedTicker = nil
            errorMessage = nil
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        let market = selectedMarket

        do {
            switch cex {
            case .bybit:
                let ticker = try await appContext.bybit.tickers(market, cache: cache)
                allTickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.hasSuffix("PERP") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USD") })
                    .filter({ $0.symbol.hasSuffix("USDT") })
                applyTickerCategoryFilters()
            case .binance:
                let ticker = try await appContext.binance.tickers(market, cache: cache)
                allTickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.contains("_") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .filter({ $0.symbol.hasSuffix("USDT") })
                    .filter({ !$0.symbol.hasPrefix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USD1") })
                    .filter({ !$0.symbol.hasPrefix("BTCUSD1") })
                    .filter({ !$0.symbol.hasPrefix("ETHBTC") })
                applyTickerCategoryFilters()
            }
        } catch {
            errorMessage = "\(error)"
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
        case .turnover:
            return sort { $0.turnover24h }
        case .priceChange:
            return sort { $0.priceChangePercent }
        case .priceChangeM:
            return sort { abs($0.priceChangePercent) }
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

        init(id: UUID = UUID(), name: String, symbols: [String] = []) {
            self.id = id
            self.name = name
            self.symbols = symbols
        }
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
        case priceChange
        case priceChangeM

        var title: String {
            switch self {
            case .turnover:
                return "Turnover 24H"
            case .priceChange:
                return "Price Change 24H"
            case .priceChangeM:
                return "Price Change 24H (Abs)"
            }
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
