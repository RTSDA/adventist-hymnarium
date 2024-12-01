import SwiftUI

struct NumericalIndexView: View {
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymnalService.hymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("#\(hymn.number) \(hymn.title)")
                                .font(.headline)
                            if let firstVerse = hymn.verses.first {
                                Text(firstVerse)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding()
                    }
                    Divider()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        NumericalIndexView()
    }
}
