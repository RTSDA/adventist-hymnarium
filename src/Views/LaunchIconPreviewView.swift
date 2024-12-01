import SwiftUI

struct LaunchIconPreviewView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.black)
                
                Text("A")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .frame(width: 200, height: 200)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    LaunchIconPreviewView()
}
