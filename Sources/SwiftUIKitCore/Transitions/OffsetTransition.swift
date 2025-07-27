import SwiftUI


public extension AnyTransition {
    
    static func offset(_ active: SIMD2<Double>, identity: SIMD2<Double> = .zero) -> AnyTransition {
        .modifier(
            active: OffsetModifier(offset: active),
            identity: OffsetModifier(offset: identity)
        )
    }
    
    static func bindedOffset(
        _ active: Binding<SIMD2<Double>>,
        identity: Binding<SIMD2<Double>> = .constant([0,0])
    ) -> AnyTransition {
        .modifier(
            active: BindingOffsetModifier(offset: active),
            identity: BindingOffsetModifier(offset: identity)
        )
    }
    
}


struct OffsetModifier: ViewModifier, Animatable {
    
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


struct BindingOffsetModifier: ViewModifier {
    
    @Binding var offset: SIMD2<Double>
    
    func body(content: Content) -> some View {
        content.offset(x: offset.x, y: offset.y)
    }
    
}
