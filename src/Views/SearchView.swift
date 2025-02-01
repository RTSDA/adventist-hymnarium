import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var hymnalService = HymnalService.shared
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    private func normalizeText(_ text: String) -> String {
        text.lowercased()
           .replacingOccurrences(of: ",", with: "")
           .replacingOccurrences(of: ".", with: "")
           .trimmingCharacters(in: .whitespaces)
    }
    
    private func splitSearchTerms(_ text: String) -> [String] {
        normalizeText(text)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }
    
    private func matchScore(hymn: Hymn, searchTerms: [String]) -> Int {
        guard !searchTerms.isEmpty else { return 0 }
        
        var score = 0
        let normalizedTitle = normalizeText(hymn.title)
        let normalizedVerses = hymn.verses.map { normalizeText($0) }
        
        // Check hymn number
        if searchTerms.contains(where: { hymn.number.description == $0 }) {
            score += 100  // High score for exact number match
        }
        
        for term in searchTerms {
            // Title matches (weighted heavily)
            if normalizedTitle.contains(term) {
                score += 50
            }
            
            // Word boundary matches in title (weighted very heavily)
            let titleWords = normalizedTitle.components(separatedBy: .whitespaces)
            if titleWords.contains(term) {
                score += 75
            }
            
            // Partial word matches in title
            if titleWords.contains(where: { $0.contains(term) }) {
                score += 25
            }
            
            // Verse matches
            for verse in normalizedVerses {
                if verse.contains(term) {
                    score += 10
                }
                
                // Word boundary matches in verses
                let verseWords = verse.components(separatedBy: .whitespaces)
                if verseWords.contains(term) {
                    score += 15
                }
            }
        }
        
        return score
    }
    
    var filteredHymns: [Hymn] {
        guard !searchText.isEmpty else { return [] }
        
        let searchTerms = splitSearchTerms(searchText)
        guard !searchTerms.isEmpty else { return [] }
        
        // Get all hymns with a non-zero match score
        let scoredHymns = hymnalService.hymns.map { hymn -> (hymn: Hymn, score: Int) in
            let score = matchScore(hymn: hymn, searchTerms: searchTerms)
            return (hymn, score)
        }
        .filter { $0.score > 0 }
        
        // Sort by score (highest first) and map back to hymns
        return scoredHymns
            .sorted { $0.score > $1.score }
            .map { $0.hymn }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search hymns", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            List {
                if searchText.isEmpty {
                    Text("Search by number, title, or lyrics")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if hymnalService.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if filteredHymns.isEmpty {
                    Text("No hymns found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredHymns) { hymn in
                        NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                            HStack {
                                Text("#\(hymn.number)")
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .leading)
                                Text(hymn.title)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            isSearchFocused = true
        }
        .task {
            await hymnalService.refreshData()
        }
    }
}
