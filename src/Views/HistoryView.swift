import SwiftUI

struct HistoryView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var recentHymnsManager = RecentHymnsManager.shared
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
        }
        .listStyle(PlainListStyle())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if !hymnalService.recentHymns.isEmpty {
                    Button(action: {
                        recentHymnsManager.clearRecentHymns()
                        Task {
                            await hymnalService.updateRecentHymns()
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .task {
            await hymnalService.updateRecentHymns()
        }
    }
}
