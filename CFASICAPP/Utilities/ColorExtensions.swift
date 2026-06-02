import SwiftUI

extension View {
    /// Applies a shadow that adapts to light/dark mode.
    /// In dark mode, uses a lighter shadow for visibility.
    func adaptiveShadow(radius: CGFloat = 8, y: CGFloat = 2) -> some View {
        modifier(AdaptiveShadowModifier(radius: radius, y: y))
    }
}

private struct AdaptiveShadowModifier: ViewModifier {
    let radius: CGFloat
    let y: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark
                ? Color.white.opacity(0.04)
                : Color.black.opacity(0.04),
            radius: radius,
            y: y
        )
    }
}
