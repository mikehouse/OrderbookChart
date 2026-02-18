
import SwiftUI

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
                HStack {
                    Text("\(tickers.count)")
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
}
