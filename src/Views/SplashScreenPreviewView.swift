import SwiftUI

struct SplashScreenPreviewView: View {
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Main Icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.3, blue: 0.7))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.1), radius: 10)
                
                // App Name
                Text("Adventist\u{2007}Hymnarium")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    SplashScreenPreviewView()
}
