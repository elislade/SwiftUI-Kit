import SwiftUI

public extension View {
    
    /// Sets the presentation context for ToolTips.
    /// - Returns: A view that will show tool tip presentations.
    @inlinable nonisolated func toolTipContext() -> some View {
        anchorPresentationContext()
    }
    
    
    /// 
    /// - Parameters:
    ///   - edge: The Edge that you want to tooltip to show on relative to this view.
    ///   - isPresented: A binded bool indicating whether the view is presented or not. Defaults to nil. Set to a non-nil binding if you want programatic access to its presentation.
    ///   - content: A view build of the content you want to show in the tool tip.
    /// - Returns: A
    nonisolated func toolTip<Tip: View>(
        edge: Edge,
        isPresented: Binding<Bool>? = nil,
        @ViewBuilder content: @MainActor @escaping () -> Tip
    ) -> some View {
        modifier(ToolTipPresenter(
            edge: edge,
            isPresented: isPresented,
            content: content
        ))
    }
    
}
