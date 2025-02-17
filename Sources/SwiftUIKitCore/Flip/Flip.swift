import SwiftUI


public extension View {
    
    ///
    /// - Parameters:
    ///   - active: A Bool indicating whether to show flipped content or not.
    ///   - horizontalEdge: The horizontal edge to flip to. Defaults to nil.
    ///   - verticalEdge: The vertical edge to flip to. Defaults to nil.
    ///   - content: A ViewBuilder of the view you want to show when flipped.
    /// - Returns: A view that will show the flipped content when isFlipped is set to true.
    func flippedContent<FlipView: View>(
        active: Bool,
        horizontalEdge: HorizontalEdge? = nil,
        verticalEdge: VerticalEdge? = nil,
        @ViewBuilder content: @escaping () -> FlipView
    ) -> some View {
        modifier(FlipModifier(
            isFlipped: active,
            horizontalEdge: horizontalEdge,
            verticalEdge: verticalEdge,
            content: content
        ))
    }
    
}
