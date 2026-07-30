
import SwiftUI

struct ContentView: View {
    
    @State private var selectedCex: Cex? = nil
    @State private var selectedTicker: Ticker? = nil
    @State private var timeframe = Cex.Interval.min1

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCex: $selectedCex)
                .navigationSplitViewColumnWidth(min: 150, ideal: 172, max: 300)
        } content: {
            SidebarContentView(
                selectedCex: $selectedCex,
                selectedTicker: $selectedTicker,
                timeframe: $timeframe
            )
                .navigationSplitViewColumnWidth(min: 310, ideal: 320, max: 340)
        } detail: {
            SidebarDetailsView(
                selectedCex: $selectedCex,
                selectedTicker: $selectedTicker,
                timeframe: $timeframe
            )
        }
        .navigationTitle("")
        .background(Color(hex: "#171A24"))
    }
}

#Preview {
    ContentView()
}
