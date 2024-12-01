import SwiftUI

// Environment key for font scaling
struct FontScaleKey: EnvironmentKey {
    static let defaultValue: Double = AppDefaults.defaultFontSize
}

extension EnvironmentValues {
    var fontScale: Double {
        get { self[FontScaleKey.self] }
        set { self[FontScaleKey.self] = newValue }
    }
}

// Font scaling modifiers
extension View {
    func scaledFont(_ style: Font.TextStyle) -> some View {
        modifier(ScaledFontModifier(style: style))
    }
    
    func scaledFontSize(_ size: Double) -> some View {
        modifier(ScaledFontSizeModifier(size: size))
    }
}

// Modifier for scaling built-in font styles
struct ScaledFontModifier: ViewModifier {
    @Environment(\.fontScale) var fontScale
    let style: Font.TextStyle
    
    private func scaledSize(for style: Font.TextStyle) -> CGFloat {
        let baseSize: CGFloat
        switch style {
        case .largeTitle: baseSize = 34
        case .title: baseSize = 28
        case .title2: baseSize = 22
        case .title3: baseSize = 20
        case .headline: baseSize = 17
        case .body: baseSize = 17
        case .callout: baseSize = 16
        case .subheadline: baseSize = 15
        case .footnote: baseSize = 13
        case .caption: baseSize = 12
        case .caption2: baseSize = 11
        @unknown default: baseSize = 17
        }
        return baseSize * (fontScale / AppDefaults.defaultFontSize)
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize(for: style)))
    }
}

// Modifier for scaling custom font sizes
struct ScaledFontSizeModifier: ViewModifier {
    @Environment(\.fontScale) var fontScale
    let size: Double
    
    func body(content: Content) -> some View {
        let scaledSize = size * (fontScale / AppDefaults.defaultFontSize)
        content.font(.system(size: scaledSize))
    }
}
