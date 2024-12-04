import SwiftUI

struct AlphabeticalIndexView: View {
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymnalService.hymns.sorted { $0.title < $1.title }) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                            
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(Color(uiColor: .label))
                        }
                        .padding(AppTheme.padding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
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
