import SwiftUI

struct RecordsView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if hymnalService.recentHymns.isEmpty {
                ContentUnavailableView(
                    "No Recent Hymns",
                    systemImage: "clock",
                    description: Text("Your recently viewed hymns will appear here.")
                )
            } else {
                ForEach(hymnalService.recentHymns, id: \.self) { hymnNumber in
                    if let hymn = hymnalService.hymn(number: hymnNumber) {
                        NavigationLink {
                            HymnDetailView(hymn: hymn)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HymnRowView(hymn: hymn)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let hymnNumber = hymnalService.recentHymns[index]
                        hymnalService.removeFromRecentHymns(hymnNumber)
                    }
                }
            }
        }
        .navigationTitle("Recent Hymns")
        .toolbar {
            if !hymnalService.recentHymns.isEmpty {
                Button(role: .destructive) {
                    hymnalService.clearRecentHymns()
                } label: {
                    Label("Clear All", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    RecordsView()
}

private struct RecordsListView: View {
    let hymnalService: HymnalService
    let recentHymns: [Int]
    let clearAction: () -> Void
    
    var body: some View {
        List {
            ForEach(recentHymns, id: \.self) { hymnNumber in
                RecentHymnRow(
                    hymn: hymnalService.hymn(number: hymnNumber)
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: clearAction) {
                    Image(systemName: "trash")
                }
                .disabled(recentHymns.isEmpty)
            }
        }
    }
}

private struct RecentHymnRow: View {
    let hymn: Hymn?
    
    var body: some View {
        if let hymn = hymn {
            NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                VStack(alignment: .leading) {
                    Text("\(hymn.number). \(hymn.title)")
                        .scaledFont(.headline)
                    if let firstVerse = hymn.verses.first {
                        Text(firstVerse)
                            .scaledFont(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
}
