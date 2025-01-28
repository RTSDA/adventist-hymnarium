import SwiftUI

struct ParticleEffect: View {
    let particleCount = 30
    @State private var particles: [(offset: CGSize, opacity: Double, scale: Double)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<particleCount, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: 4, height: 4)
                    .scaleEffect(particles.indices.contains(index) ? particles[index].scale : 0)
                    .opacity(particles.indices.contains(index) ? particles[index].opacity : 0)
                    .offset(particles.indices.contains(index) ? particles[index].offset : .zero)
            }
            .onAppear {
                particles = (0..<particleCount).map { _ in
                    let randomX = CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2)
                    let randomY = CGFloat.random(in: -geometry.size.height/2...geometry.size.height/2)
                    return (
                        offset: CGSize(width: randomX, height: randomY),
                        opacity: Double.random(in: 0.2...0.6),
                        scale: Double.random(in: 0.5...1.5)
                    )
                }
                
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    for i in particles.indices {
                        let newX = CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2)
                        let newY = CGFloat.random(in: -geometry.size.height/2...geometry.size.height/2)
                        particles[i].offset = CGSize(width: newX, height: newY)
                        particles[i].opacity = Double.random(in: 0.2...0.6)
                        particles[i].scale = Double.random(in: 0.5...1.5)
                    }
                }
            }
        }
    }
}

struct LoadingCircle: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale = 0.8
    @State private var logoOpacity = 0.0
    @State private var textScale = 0.9
    @State private var textOpacity = 0.0
    @State private var subtitleOpacity = 0.0
    @State private var showLoadingCircle = false
    @Binding var deepLinkHymnNumber: Int?
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @Environment(\.colorScheme) var colorScheme
    
    var gradientColors: [Color] {
        colorScheme == .dark ?
            [Color(red: 0.1, green: 0.2, blue: 0.4),
             Color(red: 0.05, green: 0.1, blue: 0.3)] :
            [Color(red: 0.2, green: 0.3, blue: 0.7),
             Color(red: 0.1, green: 0.2, blue: 0.5)]
    }
    
    var body: some View {
        if isActive {
            MainTabView(deepLinkHymnNumber: $deepLinkHymnNumber)
                .transition(.opacity.combined(with: .scale))
        } else {
            ZStack {
                // Animated gradient background
                LinearGradient(colors: gradientColors,
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                // Particle effect
                ParticleEffect()
                    .opacity(0.3)
                
                VStack(spacing: 20) {
                    // Logo container with shadow
                    Image("sdalogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 10) {
                        // App name with modern typography
                        Text("Adventist")
                            .font(.system(size: 36, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                        Text("HYMNARIUM")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
                    
                    // Subtitle
                    Text("Your Digital Hymnal Companion")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(subtitleOpacity)
                        .padding(.top, 5)
                    
                    if showLoadingCircle {
                        LoadingCircle()
                            .padding(.top, 30)
                    }
                }
                .padding()
            }
            .onAppear {
                // Sequence of animations
                withAnimation(.easeOut(duration: 0.8)) {
                    logoOpacity = 1
                    logoScale = 1
                }
                
                withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                    textOpacity = 1
                    textScale = 1
                }
                
                withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                    subtitleOpacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        showLoadingCircle = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(deepLinkHymnNumber: .constant(nil))
}
