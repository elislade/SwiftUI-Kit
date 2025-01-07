import SwiftUI


public extension AnyTransition {
    
    static func offset(_ simd: SIMD2<Double>) -> AnyTransition {
        .modifier(
            active: OffsetModifier(offset: simd),
            identity: OffsetModifier(offset: .zero)
        )
    }
    
}


struct OffsetModifier: ViewModifier, Hashable, Animatable {
    
    var offset: SIMD2<Double>
    
    public typealias AnimatableData = AnimatablePair<Double, Double>
    
    public nonisolated var animatableData: AnimatableData {
        get {
            AnimatableData(offset.x, offset.y)
        } set {
            offset.x = newValue.first
            offset.y = newValue.second
        }
    }
    
    nonisolated init(offset: SIMD2<Double> = .zero) {
        self.offset = offset
    }
    
    func body(content: Content) -> some View {
        content.offset(x: offset.x, y: offset.y)
    }
    
}
