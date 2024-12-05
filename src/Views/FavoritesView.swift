import SwiftUI
import Foundation
import Combine

@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favorites: Set<Int> = []
    private let hymnalService = HymnalService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var favoritesKey: String {
        "favorites_\(hymnalService.currentLanguage.id)"
    }
    
    private init() {
        loadFavorites()
        setupLanguageObserver()
    }
    
    private func loadFavorites() {
        // Clear existing favorites first
        favorites = []
        
        if let data = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            favorites = Set(data)
        }
    }
    
    private func setupLanguageObserver() {
        Task { @MainActor in
            for await language in hymnalService.$currentLanguage.values {
                loadFavorites()
            }
        }
    }
    
    func toggleFavorite(_ number: Int) {
        if favorites.contains(number) {
            favorites.remove(number)
        } else {
            favorites.insert(number)
        }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }
    
    func isFavorite(_ number: Int) -> Bool {
        favorites.contains(number)
    }
    
    func clearFavorites() {
        favorites.removeAll()
        UserDefaults.standard.removeObject(forKey: favoritesKey)
    }
}

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var readingService = ResponsiveReadingService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            if hymnalService.currentLanguage == .english1985 {
                Picker("Content Type", selection: $selectedTab) {
                    Text("Hymns").tag(0)
                    Text("Readings").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            TabView(selection: $selectedTab) {
                // Hymns Tab
                List {
                    if favoritesManager.favorites.isEmpty {
                        Text("No favorite hymns yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(favoritesManager.favorites.sorted(), id: \.self) { number in
                            if let hymn = hymnalService.hymn(number: number) {
                                NavigationLink {
                                    HymnDetailView(hymn: hymn)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(hymn.number). \(hymn.title)")
                                            .fontWeight(.medium)
                                        if let firstVerse = hymn.verses.first, !firstVerse.isEmpty {
                                            Text(firstVerse)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .tag(0)
                
                // Readings Tab
                if hymnalService.currentLanguage == .english1985 {
                    List {
                        if readingService.sortedFavoriteReadings.isEmpty {
                            Text("No favorite readings yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(readingService.sortedFavoriteReadings) { reading in
                                NavigationLink {
                                    ResponsiveReadingView(reading: reading)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(reading.number). \(reading.title)")
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .tag(1)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Favorites")
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
