import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var deepLinkHymnNumber: Int?
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    
    var body: some View {
        if isActive {
            MainTabView(deepLinkHymnNumber: $deepLinkHymnNumber)
                .environment(\.fontScale, fontSize)
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.3, blue: 0.7),
                        Color(red: 0.1, green: 0.2, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Logo container
                    Image("sdalogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .scaleEffect(size)
                        .opacity(opacity)
                    
                    // App name
                    Text("Adventist Hymnarium")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .padding(.top, 30)
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
