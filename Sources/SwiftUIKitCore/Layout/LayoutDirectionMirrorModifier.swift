import SwiftUI

/// Mirrors a view according to the layout direction of the environment
struct LayoutDirectionMirrorModifier: ViewModifier {
    
    @Environment(\.layoutDirection) private var direction
    private let enabled: Bool
    
    nonisolated init(enabled: Bool) {
        self.enabled = enabled
    }
    
    func body(content: Content) -> some View {
        content.scaleEffect(x: direction == .rightToLeft && enabled ? -1 : 1)
    }
    
}


public extension View {
    
    /// Flips the view on the x axis when  in `rightToLeft` layoutDirection.
    /// - Parameter enabled: A Bool indicating if its enbaled or not.
    /// - Returns: A view that will mirror horizontally to align to RTL layouts
    nonisolated func layoutDirectionMirror(enabled: Bool = true) -> some View {
        modifier(LayoutDirectionMirrorModifier(enabled: enabled))
    }
    
}
