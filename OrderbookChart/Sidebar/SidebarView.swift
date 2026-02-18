
import SwiftUI

struct SidebarView: View {

    @Binding var selectedCex: Cex?

    var body: some View {
        List(Cex.allCases, selection: $selectedCex) { cex in
            HStack {
                Image(cex.logo)
                    .resizable()
                    .frame(width: 18, height: 18)
                Text(cex.displayName)
            }
            .tag(cex)
        }
    }
}

#Preview {
    SidebarView(selectedCex: .constant(nil))
}
