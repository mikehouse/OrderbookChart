
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
                List(tickers, id: \.symbol, selection: $selectedTicker) { ticker in
                    Text(ticker.symbol).tag(ticker)

                }
                .scrollContentBackground(.hidden)
                .padding(.top, -8)
            }
        }
        .task(id: selectedCex?.id) {
            await loadForCurrentCex(cache: true)
        }
        .onChange(of: exportMessage) {
            if let exportMessage = exportMessage {
                print(exportMessage)
            }
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
                self.tickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.hasSuffix("PERP") })
                    .sorted(by: { $0.turnover24h > $1.turnover24h })
            case .binance:
                let ticker = try await appContext.binance.tickers(cache)
                self.tickers = ticker
                    .filter({ !$0.symbol.contains("-") })
                    .filter({ !$0.symbol.contains("_") })
                    .filter({ !$0.symbol.hasSuffix("USDC") })
                    .sorted(by: { $0.turnover24h > $1.turnover24h })
            }
        } catch {
            errorMessage = "\(error)"
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

    private enum ExportFormat: CaseIterable {
        case tradingView

        var title: String {
            switch self {
            case .tradingView:
                return "TradingView"
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
