import SwiftUI


public extension View {
    
    
    /// Adds views to the leading side of the view when swiped.
    /// - Parameter leading: A view builder of the leading content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeLeadingViews<Leading: View>(@ViewBuilder leading: @MainActor @escaping () -> Leading) -> some View {
        modifier(SwipeActionsModifier(isActive: nil, leading: leading))
    }
    
    
    /// Adds views to the leading side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - leading: A view builder of the leading content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeLeadingViews<Leading: View>(
        isActive: Binding<Bool>,
        @ViewBuilder leading: @MainActor @escaping () -> Leading
    ) -> some View {
        modifier(SwipeActionsModifier(isActive: isActive, leading: leading))
    }
    
    
    /// Adds views to the trailing side of the view when swiped.
    /// - Parameter trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeTrailingViews<Trailing: View>(@ViewBuilder trailing: @MainActor @escaping () -> Trailing) -> some View {
        modifier(SwipeActionsModifier(isActive: nil, trailing: trailing))
    }
    
    
    /// Adds views to the trailing side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeTrailingViews<Trailing: View>(
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
    func swipeViews<Leading: View, Trailing: View>(
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
    func swipeViews<Leading: View, Trailing: View>(
        activeEdge: Binding<HorizontalEdge?>,
        @ViewBuilder leading: @MainActor @escaping () -> Leading,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ) -> some View {
        modifier(SwipeActionsModifier(activeEdge: activeEdge, leading: leading, trailing: trailing))
    }
    
    
}
