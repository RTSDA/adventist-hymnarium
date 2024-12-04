import SwiftUI

struct NumericalIndexView: View {
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymnalService.hymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                            
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.textColor)
                        }
                        .padding(AppTheme.padding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                }
            }
        }
        .background(AppTheme.backgroundColor)
    }
}

#Preview {
    NavigationStack {
        NumericalIndexView()
    }
}
