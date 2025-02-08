import SwiftUI

public extension View {
    
    /// Sets the presentation context for ToolTips.
    /// - Returns: A view that will show tool tip presentations.
    nonisolated func toolTipContext() -> some View {
        anchorPresentationContext()
    }
    
    
    /// - Parameters:
    ///   - edge: The Edge that you want to tooltip to show on relative to this view.
    ///   - content: A view build of the content you want to show in the tool tip.
    /// - Returns: A ToolTipPresenter
    nonisolated func toolTip<Tip: View>(edge: Edge, @ViewBuilder content: @MainActor @escaping () -> Tip) -> some View {
        modifier(ToolTipPresenter(
            edge: edge,
            isPresented: nil,
            content: content
        ))
    }
    
    
    /// - Parameters:
    ///   - edge: The Edge that you want to tooltip to show on relative to this view.
    ///   - isPresented: A binded bool indicating whether the content is presented or not.
    ///   - content: A view build of the content you want to show in the tool tip.
    /// - Returns: A ToolTipPresenter
    nonisolated func toolTip<Tip: View>(
        edge: Edge,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @MainActor @escaping () -> Tip
    ) -> some View {
        modifier(ToolTipPresenter(
            edge: edge,
            isPresented: isPresented,
            content: content
        ))
    }
    
}
