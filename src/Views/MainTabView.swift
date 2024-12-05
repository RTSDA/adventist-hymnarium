import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var screenService = ScreenService.shared
    @StateObject private var audioService = AudioService.shared
    @AppStorage("showMiniPlayer") private var showMiniPlayer = true
    @State private var selectedTab = 0
    @Binding var deepLinkHymnNumber: Int?
    
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
        }
    }
}
