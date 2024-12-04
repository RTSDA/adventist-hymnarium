import SwiftUI

struct ThematicListView: View {
    let thematicList: ThematicList
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(thematicList.ambits) { ambit in
                    NavigationLink(destination: ThematicHymnsListView(ambit: ambit)) {
                        HStack {
                            Text("#\(ambit.start)-\(ambit.end)")
                                .font(AppTheme.standardFont)
                                .foregroundColor(AppTheme.accentColor)
                                .frame(width: 50, alignment: .leading)
                            
                            Text(ambit.ambit)
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
        .navigationTitle(thematicList.thematic)
    }
}

struct ThematicSubGroupView: View {
    let thematicList: ThematicList
    
    var body: some View {
        List {
            ForEach(thematicList.ambits) { ambit in
                NavigationLink {
                    ThematicHymnsListView(ambit: ambit)
                } label: {
                    VStack(alignment: .leading) {
                        Text(ambit.ambit)
                            .scaledFont(.headline)
                        Text("Hymns \(ambit.start)-\(ambit.end)")
                            .scaledFont(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(thematicList.thematic)
    }
}

struct ThematicHymnsListView: View {
    let ambit: ThematicAmbit
    @StateObject private var hymnalService = HymnalService.shared
    
    var hymns: [Hymn] {
        hymnalService.hymns(in: ambit)
    }
    
    var body: some View {
        List {
            ForEach(hymns) { hymn in
                NavigationLink {
                    HymnDetailView(hymn: hymn)
                } label: {
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
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(ambit.ambit)
    }
}

#Preview {
    NavigationView {
        ThematicListView(thematicList: ThematicList(
            thematic: "Categories",
            ambits: [
                ThematicAmbit(ambit: "Worship", start: 1, end: 20, backgroundImage: nil),
                ThematicAmbit(ambit: "God's Love", start: 21, end: 40, backgroundImage: nil),
                ThematicAmbit(ambit: "Praise", start: 41, end: 60, backgroundImage: nil)
            ]
        ))
    }
}
