//
//  AdventistHymnariumApp.swift
//  Adventist Hymnarium
//
//  Created by Benjamin Slingo on 11/28/24.
//

import SwiftUI

@main
struct AdventistHymnariumApp: App {
    init() {
        // Set the display name programmatically
        if let displayName = Bundle.main.displayName {
            UserDefaults.standard.set(displayName, forKey: "DisplayName")
        }
    }
    
    @StateObject private var hymnalService = HymnalService.shared
    @State private var deepLinkHymnNumber: Int?
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(hymnalService)
                .environment(\.fontScale, fontSize)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // First check if it's just the base URL
        if (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium") && url.host == nil {
            // Just open the app without a specific hymn
            return
        }
        
        // Then check for specific hymn deep linking
        guard (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium"),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host,
              host == "hymn",
              let hymnNumberString = components.queryItems?.first(where: { $0.name == "number" })?.value,
              let hymnNumber = Int(hymnNumberString) else {
            return
        }
        deepLinkHymnNumber = hymnNumber
    }
}
