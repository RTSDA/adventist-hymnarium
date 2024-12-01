import SwiftUI

struct HymnListView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @State private var searchText = ""
    @Binding var deepLinkHymnNumber: Int?
    
    var filteredHymns: [Hymn] {
        if searchText.isEmpty {
            return hymnalService.hymns
        }
        return hymnalService.hymns.filter { hymn in
            hymn.title.localizedCaseInsensitiveContains(searchText) ||
            String(hymn.number).contains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredHymns) { hymn in
                NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                    HymnRow(hymn: hymn)
                }
            }
            .navigationTitle("Adventist Hymnarium")
            .searchable(text: $searchText, prompt: "Search hymns...")
            .overlay {
                if hymnalService.isLoading {
                    ProgressView()
                }
            }
        }
        .onChange(of: deepLinkHymnNumber) { oldValue, newValue in
            if let number = newValue,
               let hymn = hymnalService.hymn(number: number) {
                // Clear the deep link number so we don't navigate again
                deepLinkHymnNumber = nil
                
                // Push the hymn detail view
                let detailView = HymnDetailView(hymn: hymn)
                let hostingController = UIHostingController(rootView: detailView)
                
                // Get the current navigation controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let tabBarController = window.rootViewController as? UITabBarController,
                   let navigationController = tabBarController.selectedViewController as? UINavigationController {
                    navigationController.pushViewController(hostingController, animated: true)
                }
            }
        }
    }
}

struct HymnRow: View {
    let hymn: Hymn
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(hymn.number). \(hymn.title)")
                .scaledFont(.body)
            
            if let verse = hymn.verses.first {
                Text(verse)
                    .scaledFont(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HymnListView(deepLinkHymnNumber: .constant(nil))
    }
}
