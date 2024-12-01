import SwiftUI

class RecentHymnsManager: ObservableObject {
    static let shared = RecentHymnsManager()
    
    @Published private(set) var recentHymns: [Int] = []
    @AppStorage("maxRecentHymns") private var maxRecentHymns = 10
    private let recentHymnsKey = "recentHymns"
    
    private init() {
        loadRecentHymns()
    }
    
    private func loadRecentHymns() {
        if let data = UserDefaults.standard.array(forKey: recentHymnsKey) as? [Int] {
            recentHymns = Array(data.prefix(maxRecentHymns))
        }
    }
    
    private func saveRecentHymns() {
        UserDefaults.standard.set(recentHymns, forKey: recentHymnsKey)
    }
    
    func addRecentHymn(_ hymnNumber: Int) {
        // Remove if already exists
        recentHymns.removeAll { $0 == hymnNumber }
        
        // Add to beginning
        recentHymns.insert(hymnNumber, at: 0)
        
        // Trim to max size
        if recentHymns.count > maxRecentHymns {
            recentHymns = Array(recentHymns.prefix(maxRecentHymns))
        }
        
        saveRecentHymns()
    }
    
    func clearRecentHymns() {
        recentHymns.removeAll()
        saveRecentHymns()
    }
}

struct RecordsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var recentHymnsManager = RecentHymnsManager.shared
    
    var body: some View {
        NavigationView {
            RecordsListView(
                hymnalService: hymnalService,
                recentHymns: recentHymnsManager.recentHymns,
                clearAction: recentHymnsManager.clearRecentHymns
            )
            .navigationTitle("Recent Hymns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
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
