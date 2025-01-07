import SwiftUI


struct ClipShapeModifier<S: Shape>: ViewModifier {
    
    let shape: S
    let style: FillStyle
    
    nonisolated init(shape: S, style: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content.clipShape(shape, style: style)
    }
    
}


struct ZIndexModifier: ViewModifier, Hashable {
    
    let index: Double
    
    nonisolated init(index: Double = 0) {
        self.index = index
    }
    
    func body(content: Content) -> some View {
        content.zIndex(index)
    }
    
}
