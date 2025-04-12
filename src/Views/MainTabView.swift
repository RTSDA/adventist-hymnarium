import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var screenService = ScreenService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var readingService = ResponsiveReadingService.shared
    @AppStorage("showMiniPlayer") private var showMiniPlayer = true
    @State private var selectedTab = 0
    @Binding var deepLinkHymnNumber: Int?
    @State private var navigateToHymn = false
    @State private var selectedHymn: Hymn?
    @State private var selectedReading: ResponsiveReading?
    
    private var safeAreaBottom: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return 0 }
        return window.safeAreaInsets.bottom
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                NumberPadView()
                    .safeAreaInset(edge: .bottom) {
                        if showMiniPlayer && audioService.currentHymnNumber != nil {
                            MiniPlayerView()
                                .background(Color(UIColor.systemBackground))
                                .overlay(alignment: .bottom) {
                                    Divider()
                                }
                        }
                    }
                    .navigationDestination(isPresented: $navigateToHymn) {
                        if let hymn = selectedHymn {
                            HymnDetailView(hymn: hymn)
                        } else if let reading = selectedReading {
                            ResponsiveReadingView(reading: reading)
                        }
                    }
            }
            .tabItem {
                Label("Number", systemImage: "number")
                    .environment(\.symbolRenderingMode, .hierarchical)
            }
            .tag(0)
            
            NavigationStack {
                IndexView()
                    .safeAreaInset(edge: .bottom) {
                        if showMiniPlayer && audioService.currentHymnNumber != nil {
                            MiniPlayerView()
                                .background(Color(UIColor.systemBackground))
                                .overlay(alignment: .bottom) {
                                    Divider()
                                }
                        }
                    }
            }
            .tabItem {
                Label("Index", systemImage: "list.bullet")
                    .environment(\.symbolRenderingMode, .hierarchical)
            }
            .tag(1)
            
            NavigationStack {
                FavoritesView()
                    .safeAreaInset(edge: .bottom) {
                        if showMiniPlayer && audioService.currentHymnNumber != nil {
                            MiniPlayerView()
                                .background(Color(UIColor.systemBackground))
                                .overlay(alignment: .bottom) {
                                    Divider()
                                }
                        }
                    }
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
                    .environment(\.symbolRenderingMode, .hierarchical)
            }
            .tag(2)
            
            NavigationStack {
                SettingsView()
                    .safeAreaInset(edge: .bottom) {
                        if showMiniPlayer && audioService.currentHymnNumber != nil {
                            MiniPlayerView()
                                .background(Color(UIColor.systemBackground))
                                .overlay(alignment: .bottom) {
                                    Divider()
                                }
                        }
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
                    .environment(\.symbolRenderingMode, .hierarchical)
            }
            .tag(3)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
            
            // Handle deep link if present
            handleDeepLink()
        }
        .onChange(of: deepLinkHymnNumber) { oldValue, newValue in
            handleDeepLink()
        }
    }
    
    private func handleDeepLink() {
        // First check for reading deep link
        if let readingNumber = UserDefaults.standard.object(forKey: "DeepLinkReadingNumber") as? Int {
            if hymnalService.currentLanguage == .english1985 && readingNumber >= 696 && readingNumber <= 920,
               let reading = readingService.reading(number: readingNumber) {
                selectedTab = 0 // Switch to number pad tab
                selectedReading = reading
                selectedHymn = nil
                navigateToHymn = true
                
                // Clear the reading number from UserDefaults
                UserDefaults.standard.removeObject(forKey: "DeepLinkReadingNumber")
                return
            }
        }
        
        // Then check for hymn deep link
        guard let hymnNumber = deepLinkHymnNumber else { return }
        
        // Check for responsive reading first (only in 1985 hymnal)
        if hymnalService.currentLanguage == .english1985 && hymnNumber >= 696 && hymnNumber <= 920,
           let reading = readingService.reading(number: hymnNumber) {
            selectedTab = 0 // Switch to number pad tab
            selectedReading = reading
            selectedHymn = nil
            navigateToHymn = true
            
            // Clear the deep link after handling
            deepLinkHymnNumber = nil
        } else if let hymn = hymnalService.hymn(number: hymnNumber) {
            selectedTab = 0 // Switch to number pad tab
            selectedHymn = hymn
            selectedReading = nil
            navigateToHymn = true
            
            // Clear the deep link after handling
            deepLinkHymnNumber = nil
        } else {
            // If the hymn isn't found, we need to wait for hymnal service to load
            Task {
                await hymnalService.refreshData()
                if hymnalService.currentLanguage == .english1985 {
                    await readingService.loadReadings()
                }
                
                // Try again after data is loaded
                if let hymn = hymnalService.hymn(number: hymnNumber) {
                    selectedTab = 0
                    selectedHymn = hymn
                    selectedReading = nil
                    navigateToHymn = true
                    
                    // Clear the deep link after handling
                    deepLinkHymnNumber = nil
                }
            }
        }
    }
}
