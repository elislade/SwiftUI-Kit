import SwiftUI


public extension AnyTransition {
    
    static func frame(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> AnyTransition {
        .modifier(
            active: FrameRangeModifier(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment),
            identity: FrameRangeModifier(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        )
    }
    
}


struct FrameRangeModifier: ViewModifier {
    
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment
    
    nonisolated init(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment)
    }
    
}
