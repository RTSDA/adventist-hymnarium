import SwiftUI

struct ThematicIndexContent: View {
    @StateObject private var viewModel = ThematicIndexViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    viewModel.loadData()
                }
            } else {
                thematicListContent
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var thematicListContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.thematicLists) { list in
                    thematicListRow(list)
                    Divider()
                }
            }
        }
        .navigationTitle("Thematic Index")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func thematicListRow(_ list: ThematicList) -> some View {
        NavigationLink {
            ThematicListDetailView(list: list)
        } label: {
            VStack(alignment: .leading) {
                Text(list.thematic)
                    .font(AppTheme.standardFont)
                    .foregroundColor(AppTheme.textColor)
                Text("\(list.ambits.count) sections")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
            .padding(AppTheme.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ThematicHymnListView: View {
    let title: String
    let hymns: [Hymn]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymns) { hymn in
                    NavigationLink {
                        HymnDetailView(hymn: hymn)
                    } label: {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                                .frame(width: 50, alignment: .leading)
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.textColor)
                                .lineLimit(2)
                        }
                        .padding(AppTheme.padding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                }
            }
        }
        .background(AppTheme.backgroundColor)
        .navigationTitle(title)
    }
}

struct ThematicIndexContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ThematicIndexContent()
        }
    }
}
