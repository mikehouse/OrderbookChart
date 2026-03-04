
import SwiftUI

struct ContentView: View {
    
    @State private var selectedCex: Cex? = nil
    @State private var selectedTicker: Ticker? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCex: $selectedCex)
                .navigationSplitViewColumnWidth(172)
        } content: {
            SidebarContentView(selectedCex: $selectedCex, selectedTicker: $selectedTicker)
                .navigationSplitViewColumnWidth(292)
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
