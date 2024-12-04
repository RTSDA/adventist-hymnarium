import SwiftUI

struct ThematicIndexContent: View {
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymnalService.thematicLists) { list in
                    if list.ambits.count == 1, let ambit = list.ambits.first {
                        let hymns = ambit.getHymns(from: hymnalService.hymns)
                        NavigationLink {
                            ThematicHymnListView(title: list.thematic, hymns: hymns)
                        } label: {
                            HStack {
                                Text("#\(list.thematic)")
                                    .font(AppTheme.standardFont)
                                    .foregroundColor(AppTheme.accentColor)
                                    .frame(width: 70, alignment: .leading)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.thematic)
                                        .font(AppTheme.standardFont)
                                        .foregroundColor(AppTheme.textColor)
                                    Text("\(hymns.count) hymns")
                                        .font(AppTheme.standardFont)
                                        .foregroundColor(AppTheme.textColor)
                                }
                            }
                            .padding(AppTheme.padding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                            .padding(.leading)
                    } else {
                        NavigationLink {
                            ThematicSubGroupView(thematicList: list)
                        } label: {
                            HStack {
                                Text("#\(list.thematic)")
                                    .font(AppTheme.standardFont)
                                    .foregroundColor(AppTheme.accentColor)
                                    .frame(width: 70, alignment: .leading)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.thematic)
                                        .font(AppTheme.standardFont)
                                        .foregroundColor(AppTheme.textColor)
                                    Text("\(list.ambits.count) categories")
                                        .font(AppTheme.standardFont)
                                        .foregroundColor(AppTheme.textColor)
                                }
                            }
                            .padding(AppTheme.padding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .background(AppTheme.backgroundColor)
    }
}

struct ThematicHymnListView: View {
    let title: String
    let hymns: [Hymn]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(hymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        HStack {
                            Text("#\(hymn.number)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                                .frame(width: 50, alignment: .leading)
                            Text(hymn.title)
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                        }
                        .padding(AppTheme.padding)
                        .padding(.vertical, 12)
                    }
                    Divider()
                        .padding(.leading)
                }
            }
        }
        .background(AppTheme.backgroundColor)
        .navigationTitle(title)
    }
}
