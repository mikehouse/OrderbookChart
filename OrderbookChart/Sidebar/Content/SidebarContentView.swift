
import SwiftUI
import UniformTypeIdentifiers

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
    @State private var tickers: [Ticker] = []
    @State private var customTickerSections: [TickerSection] = []
    @State private var newSectionName = ""
    @State private var tickerSortRule: TickerSortRule = .turnover
    @State private var exportFormat: ExportFormat = .tradingView
    @State private var splitCount: Int = 100
    @State private var exportMessage: String?
    @State private var isSelectingExportDirectory = false
    @State private var rateLimitPercent: Int = 0

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
            } else if tickers.isEmpty {
                Text(selectedCex == nil ? "Select an exchange" : "No tickers available")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tickers: \(tickers.count)")
                        Spacer()
                        Button(action: {
                            Task {
                                await loadForCurrentCex(cache: false)
                            }
                        }, label: {
                            Image(systemName: "arrow.counterclockwise")
                        })
                        .buttonStyle(.borderedProminent)
                    }
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
                                ForEach([100, 150, 200, 250], id: \.self) { count in
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
        .task(id: selectedCex?.id) {
            await loadForCurrentCex(cache: true)
        }
        .task {
            loadCustomTickerSections()
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
            tickers = sortedTickers(tickers)
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
            switch result {
            case .success(let urls):
                guard let directoryURL = urls.first else {
                    exportMessage = "Export canceled."
                    return
                }
                exportTickers(to: directoryURL)
            case .failure(let error):
                exportMessage = "Export failed: \(error.localizedDescription)"
            }
        }
    }

    private var trimmedNewSectionName: String {
        newSectionName.trimmingCharacters(in: .whitespacesAndNewlines)
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
        let tickerBySymbol = Dictionary(uniqueKeysWithValues: tickers.map { ($0.symbol, $0) })
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
            tickers = []
            selectedTicker = nil
            errorMessage = nil
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            switch cex {
            case .bybit:
                let ticker = try await appContext.bybit.tickers(cache)
                self.tickers = sortedTickers(ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.hasSuffix("PERP") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .filter({ !$0.symbol.hasPrefix("USD") })
                )
            case .binance:
                let ticker = try await appContext.binance.tickers(cache)
                self.tickers = sortedTickers(ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.contains("_") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                )
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

    private func exportTickers(to directoryURL: URL) {
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
                let chunks = tickers.chunked(by: splitCount)
                let timestamp = Self.exportDateFormatter.string(from: Date())
                let cexName = selectedCex.displayName
                let cexNameUppercased = cexName.uppercased()

                for (index, chunk) in chunks.enumerated() {
                    let symbols = chunk.map { "\(cexNameUppercased):\($0.symbol).P" }.joined(separator: ",")
                    let fileName = "\(cexName)-\(chunk.count)-\(timestamp)-\(index + 1).txt"
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
}

private extension Array {
    func chunked(by size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
