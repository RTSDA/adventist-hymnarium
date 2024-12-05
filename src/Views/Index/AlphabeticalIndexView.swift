import SwiftUI

struct AlphabeticalIndexView: View {
    @StateObject private var viewModel = IndexViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                List(viewModel.alphabeticallySortedHymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                                .frame(width: 50, alignment: .trailing)
                            
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.textColor)
                        }
                    }
                }
                .navigationTitle("Alphabetical Index")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
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
