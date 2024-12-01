import SwiftUI

struct AlphabeticalIndexView: View {
    @StateObject private var hymnalService = HymnalService.shared
    private let sections: [AlphabeticalSection]
    
    struct AlphabeticalSection: Identifiable {
        let id = UUID()
        let title: String
        let hymns: [Hymn]
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(sections) { section in
                    SwiftUI.Section {
                        ForEach(section.hymns) { hymn in
                            NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                                HymnRowView(hymn: hymn)
                            }
                            Divider()
                        }
                    } header: {
                        Text(section.title)
                            .scaledFont(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    init() {
        let groupedHymns = Dictionary(grouping: HymnalService.shared.hymns) { hymn in
            // Remove leading apostrophe for grouping
            let title = hymn.title.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
            return String(title.prefix(1)).uppercased()
        }
        
        let sortedSections = groupedHymns.map { key, hymns in
            // Sort hymns by title, ignoring leading apostrophes
            let sortedHymns = hymns.sorted { hymn1, hymn2 in
                let title1 = hymn1.title.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
                let title2 = hymn2.title.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
                return title1 < title2
            }
            return AlphabeticalSection(title: key, hymns: sortedHymns)
        }.sorted { $0.title < $1.title }
        
        self.sections = sortedSections
    }
}

struct HymnRowView: View {
    let hymn: Hymn
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("#\(hymn.number) \(hymn.title)")
                .scaledFont(.headline)
            if let firstVerse = hymn.verses.first {
                Text(firstVerse)
                    .scaledFont(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
    }
}

struct AlphabeticalIndexView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AlphabeticalIndexView()
        }
    }
}
