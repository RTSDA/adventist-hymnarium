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
                            VStack(alignment: .leading, spacing: 4) {
                                Text(list.thematic)
                                    .scaledFont(.headline)
                                    .foregroundColor(.primary)
                                Text("\(hymns.count) hymns")
                                    .scaledFont(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.vertical, 12)
                        }
                        Divider()
                            .padding(.leading)
                    } else {
                        NavigationLink {
                            ThematicSubGroupView(thematicList: list)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(list.thematic)
                                    .scaledFont(.headline)
                                    .foregroundColor(.primary)
                                Text("\(list.ambits.count) categories")
                                    .scaledFont(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.vertical, 12)
                        }
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
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
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .leading)
                            Text(hymn.title)
                                .scaledFont(.headline)
                            Spacer()
                        }
                        .padding()
                        .padding(.vertical, 12)
                    }
                    Divider()
                        .padding(.leading)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
    }
}
