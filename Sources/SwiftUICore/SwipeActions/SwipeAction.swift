import SwiftUI


public extension View {
    
    
    /// Adds views to the leading side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - leading: A view builder of the leading content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeLeadingViews<Leading: View>(
        isActive: Binding<Bool> = .constant(false),
        @ViewBuilder leading: @escaping () -> Leading
    ) -> some View {
        modifier(SwipeActionsModifier(isActive: isActive, leading: leading))
    }
    
    
    /// Adds views to the trailing side of the view when swiped.
    /// - Parameters:
    ///   - isActive : Binding to the views presented state.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeTrailingViews<Trailing: View>(
        isActive: Binding<Bool> = .constant(false),
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(SwipeActionsModifier(isActive: isActive, trailing: trailing))
    }
    
    
    /// Adds views to the leading and trailing side of the view when swiped.
    /// - Parameters:
    ///   - activeEdges: Binding to `HorizontalEdge.Set` that is currently active.
    ///   - leading: A view builder of the leading content.
    ///   - trailing: A view builder of the trailing content.
    /// - Returns: A  modified view that responds to swipe gestures.
    func swipeViews<Leading: View, Trailing: View>(
        activeEdge: Binding<HorizontalEdge.Set> = .constant([]),
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(SwipeActionsModifier(activeEdge: activeEdge, leading: leading, trailing: trailing))
    }
    
    
}
