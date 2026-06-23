
import SwiftUI

struct ContentView: View {
    
    @State private var selectedCex: Cex? = nil
    @State private var selectedTicker: Ticker? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCex: $selectedCex)
                .navigationSplitViewColumnWidth(min: 150, ideal: 172, max: 300)
        } content: {
            SidebarContentView(selectedCex: $selectedCex, selectedTicker: $selectedTicker)
                .navigationSplitViewColumnWidth(min: 300, ideal: 300, max: 400)
        } detail: {
            SidebarDetailsView(selectedCex: $selectedCex, selectedTicker: $selectedTicker)
        }
        .navigationTitle("")
        .background(Color(hex: "#171A24"))
    }
}

#Preview {
    ContentView()
}
