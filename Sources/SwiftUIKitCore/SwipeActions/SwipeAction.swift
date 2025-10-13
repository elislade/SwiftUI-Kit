import SwiftUI


extension View {
    
    /// Set how child swipe views should invalidate.
    /// - Note: Parents that also set this are included unless `.none` is set, superseding any parent.
    /// - Parameter invalidation: An OptionSet of all things that should invalidate a swiped cell.
    /// - Returns: A modified view.
    public nonisolated func swipeActionInvalidation(_ invalidation: SwipeActionInvalidation) -> some View {
        InlineBinding(Optional<UUID>(nil)){ id in
            transformEnvironment(\.activeSwipeID){ value in
                if invalidation.contains(.onOpen) {
                    value = id
                } else if invalidation == .none {
                    value = .constant(nil)
                }
            }
        }
        .transformEnvironment(\.invalidateSwipeWhenMoved){ value in
            if invalidation.contains(.onMove) {
                value = true
            } else if invalidation == .none {
                value = false
            }
        }
    }
    
    
    /// Adds views to the leading side of the view when swiped.
    /// - Parameter leading: A view builder of the leading content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeLeadingViews<Leading: View>(@ViewBuilder leading: @MainActor @escaping () -> Leading) -> some View {
        modifier(SwipeActionsModifier(isActive: nil, leading: leading))
    }
    
    
    /// Adds views to the leading side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - leading: A view builder of the leading content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeLeadingViews<Leading: View>(
        isActive: Binding<Bool>,
        @ViewBuilder leading: @MainActor @escaping () -> Leading
    ) -> some View {
        modifier(SwipeActionsModifier(isActive: isActive, leading: leading))
    }
    
    
    /// Adds views to the trailing side of the view when swiped.
    /// - Parameter trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeTrailingViews<Trailing: View>(@ViewBuilder trailing: @MainActor @escaping () -> Trailing) -> some View {
        modifier(SwipeActionsModifier(isActive: nil, trailing: trailing))
    }
    
    
    /// Adds views to the trailing side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeTrailingViews<Trailing: View>(
        isActive: Binding<Bool>,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ) -> some View {
        modifier(SwipeActionsModifier(isActive: isActive, trailing: trailing))
    }
    
    
    /// Adds views to the leading and trailing side of the view when swiped.
    /// - Parameters:
    ///   - leading: A view builder of the leading content.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeViews<Leading: View, Trailing: View>(
        @ViewBuilder leading: @MainActor @escaping () -> Leading,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ) -> some View {
        modifier(SwipeActionsModifier(activeEdge: nil, leading: leading, trailing: trailing))
    }
    
    
    /// Adds views to the leading and trailing side of the view when swiped.
    /// - Parameters:
    ///   - activeEdge: Binding to `HorizontalEdge` that is currently active.
    ///   - leading: A view builder of the leading content.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    public nonisolated func swipeViews<Leading: View, Trailing: View>(
        activeEdge: Binding<HorizontalEdge?>,
        @ViewBuilder leading: @MainActor @escaping () -> Leading,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ) -> some View {
        modifier(
            SwipeActionsModifier(activeEdge: activeEdge, leading: leading, trailing: trailing)
        )
    }
    
    
}


public struct SwipeActionInvalidation: OptionSet, Hashable, Sendable, BitwiseCopyable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static var none: Self { [] }
    
    /// Invalidates previously open view when another opens.
    public static let onOpen = Self(rawValue: 1 << 0)
    
    /// Invalidates when the view moves from the position from where it was opened from.
    public static let onMove = Self(rawValue: 1 << 1)
    
}
