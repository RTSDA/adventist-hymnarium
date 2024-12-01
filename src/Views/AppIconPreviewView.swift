import SwiftUI

struct AppIconPreviewView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.7), // Deep blue
                    Color(red: 0.1, green: 0.2, blue: 0.5)  // Darker blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(22) // iOS app icon corner radius
            
            // Three Bible pages with slight rotation
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white)
                    .frame(width: 70, height: 90)
                    .rotationEffect(.degrees(Double(index * 3 - 3)))
                    .offset(x: CGFloat(index * 2 - 2), y: CGFloat(index * -2 + 2))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            }
            
            // Musical note overlay
            VStack(spacing: 0) {
                Image(systemName: "music.note")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                // Small cross beneath
                Image(systemName: "cross.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .offset(y: -5)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: 120, height: 120) // Standard size for preview
    }
}

struct IconPreviewScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Show icon at different sizes
                HStack(spacing: 20) {
                    // App Store size
                    AppIconPreviewView()
                        .frame(width: 120, height: 120)
                    
                    // iPhone home screen size
                    AppIconPreviewView()
                        .frame(width: 60, height: 60)
                    
                    // Settings size
                    AppIconPreviewView()
                        .frame(width: 29, height: 29)
                }
                
                // Show on mock iPhone home screen
                ZStack {
                    Color(.systemGray6)
                        .frame(width: 250, height: 300)
                        .cornerRadius(30)
                    
                    VStack(spacing: 20) {
                        AppIconPreviewView()
                            .frame(width: 60, height: 60)
                        Text("Adventist Hymnarium")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("App Icon Preview")
        }
    }
}

#Preview {
    IconPreviewScreen()
}
