import UIKit

class ScreenService: ObservableObject {
    static let shared = ScreenService()
    
    @Published private(set) var isScreenLockEnabled = false
    
    private init() {
        // Load initial state from UserDefaults
        isScreenLockEnabled = UserDefaults.standard.bool(forKey: "keepScreenOn")
        
        // Observe changes to the setting
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenLockChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleScreenLockChange() {
        let shouldKeepScreenOn = UserDefaults.standard.bool(forKey: "keepScreenOn")
        if shouldKeepScreenOn != isScreenLockEnabled {
            setScreenLock(enabled: shouldKeepScreenOn)
        }
    }
    
    private func setScreenLock(enabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = enabled
        isScreenLockEnabled = enabled
    }
}
