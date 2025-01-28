import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var hymnalService = HymnalService.shared
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    private func normalizeText(_ text: String) -> String {
        text.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
    }
    
    var filteredHymns: [Hymn] {
        guard !searchText.isEmpty else { return [] }
        
        let normalizedSearchText = normalizeText(searchText)
        
        return hymnalService.hymns.filter { hymn in
            // Check hymn number
            if let searchNumber = Int(searchText),
               hymn.number == searchNumber {
                return true
            }
            
            // Check title
            let normalizedTitle = normalizeText(hymn.title)
            if normalizedTitle.localizedCaseInsensitiveContains(normalizedSearchText) {
                return true
            }
            
            // Check verses
            for verse in hymn.verses {
                if verse.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }
            
            return false
        }
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
