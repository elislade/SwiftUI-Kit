import SwiftUI


public extension View {
    
    /// Sets the context that compares child inset preferences and decides what their insets should be.
    /// Default behaviour is to use the largest inset for each edge of each preference.
    /// - Returns: A view with associated  modifier.
    nonisolated func equalInsetContext(defaultInsets: EdgeInsets) -> some View {
        modifier(EqualInsetContext(defaultInsets: defaultInsets))
    }
    
    /// Defines this view as an `EqualInsetItem` which means it applies an equal inset determined by its siblings in the nearest `EqualInsetContext`.
    /// - Returns: A view with associated  modifier.
    nonisolated func equalInsetItem() -> some View {
        modifier(EqualInsetItemModifier(proposal: nil))
    }
    
    /// Defines this view as an `EqualInsetItem` which means it applies an equal inset determined by its siblings in the nearest `EqualInsetContext`.
    /// - Parameters:
    ///   - edges: An `Edge.Set` that is relevant to the following value as a proposal to the nearest `EqualInsetContext`.
    ///   - value: A `CGFloat` that is relevant to the preceding specified edges as a proposal to the nearest `EqualInsetContext`.
    /// - Returns: A view with associated modifier.
    nonisolated func equalInsetItem(_ edges: Edge.Set = .all, _ value: CGFloat) -> some View {
        modifier(EqualInsetItemModifier(
            proposal: {
                var e = EdgeInsets()
                e.set(edges: edges, value: value)
                return e
            }()
        ))
    }
    
    nonisolated func onEqualInsetChange<V: Equatable>(
        for transform: @escaping (EdgeInsets) -> V,
        action: @escaping (V) -> Void
    ) -> some View {
        modifier(OnEqualInsetChangeModifier(transform: transform, action: action))
    }
    
    nonisolated func onEqualInsetChange(action: @escaping (EdgeInsets) -> Void) -> some View {
        modifier(OnEqualInsetChangeModifier(transform: { $0 }, action: action))
    }
    
}
