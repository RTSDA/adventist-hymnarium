import SwiftUI

struct ThematicListView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Index Type", selection: $selectedTab) {
                    Text("Categories").tag(0)
                    Text("Alphabetical").tag(1)
                    Text("Numerical").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    ThematicIndexContent()
                        .tag(0)
                    
                    AlphabeticalIndexView()
                        .tag(1)
                    
                    NumericalIndexView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Index")
        }
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
    ThematicListView()
}
