//
//  AdventistHymnariumApp.swift
//  Adventist Hymnarium
//
//  Created by Benjamin Slingo on 11/28/24.
//

import SwiftUI

@main
struct AdventistHymnariumApp: App {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var storage = StorageService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var screenService = ScreenService.shared
    @State private var deepLinkHymnNumber: Int?
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    
    init() {
        // Set the display name programmatically
        if let displayName = Bundle.main.displayName {
            UserDefaults.standard.set(displayName, forKey: "DisplayName")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView(deepLinkHymnNumber: $deepLinkHymnNumber)
                .environmentObject(hymnalService)
                .environmentObject(storage)
                .environmentObject(audioService)
                .environmentObject(screenService)
                .environment(\.fontScale, fontSize)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("Handling deep link: \(url.absoluteString)")
        
        // First check if it's just the base URL
        if (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium") && url.host == nil {
            // Just open the app without a specific hymn
            return
        }
        
        // Handle the format: adventisthymnarium://hymn?number=123
        if (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium") && url.host == "hymn" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let hymnNumberItem = components.queryItems?.first(where: { $0.name == "number" }),
               let hymnNumberString = hymnNumberItem.value,
               let hymnNumber = Int(hymnNumberString) {
                print("Opening hymn #\(hymnNumber) from deep link")
                deepLinkHymnNumber = hymnNumber
                return
            }
        }
        
        // Handle the format: adventisthymnarium://reading?number=123
        if (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium") && url.host == "reading" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let readingNumberItem = components.queryItems?.first(where: { $0.name == "number" }),
               let readingNumberString = readingNumberItem.value,
               let readingNumber = Int(readingNumberString) {
                print("Opening reading #\(readingNumber) from deep link")
                // Store the reading number in UserDefaults to be picked up by the app
                UserDefaults.standard.set(readingNumber, forKey: "DeepLinkReadingNumber")
                return
            }
        }
        
        // Then check for specific hymn deep linking (legacy format)
        guard (url.scheme == "hymnarium" || url.scheme == "adventisthymnarium"),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host,
              host == "hymn",
              let hymnNumberString = components.queryItems?.first(where: { $0.name == "number" })?.value,
              let hymnNumber = Int(hymnNumberString) else {
            print("Invalid deep link format")
            return
        }
        deepLinkHymnNumber = hymnNumber
    }
}
