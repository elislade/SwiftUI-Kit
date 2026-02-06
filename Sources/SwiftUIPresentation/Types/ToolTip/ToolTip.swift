import SwiftUI

extension View {
    
    /// Sets the presentation context for ToolTips.
    /// - Returns: A view that will show tool tip presentations.
    nonisolated public func toolTipContext() -> some View {
        anchorPresentationContext()
    }
    
    
    /// - Parameters:
    ///   - edge: The Edge that you want to tooltip to show on relative to this view.
    ///   - content: A view build of the content you want to show in the tool tip.
    /// - Returns: A ToolTipPresenter
    nonisolated public func toolTip(axis: Axis, @ViewBuilder content: @MainActor @escaping () -> some View) -> some View {
        modifier(ToolTipPresenter(
            axis: axis,
            isPresented: nil,
            content: content
        ))
    }
    
    
    /// - Parameters:
    ///   - edge: The Edge that you want to tooltip to show on relative to this view.
    ///   - isPresented: A binded bool indicating whether the content is presented or not.
    ///   - content: A view build of the content you want to show in the tool tip.
    /// - Returns: A ToolTipPresenter
    nonisolated public func toolTip(
        axis: Axis,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(ToolTipPresenter(
            axis: axis,
            isPresented: isPresented,
            content: content
        ))
    }
    
}
