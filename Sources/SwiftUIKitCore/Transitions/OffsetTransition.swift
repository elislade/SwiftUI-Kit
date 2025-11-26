import SwiftUI


public extension AnyTransition {
    
    static func offset(_ active: SIMD2<Double>, identity: SIMD2<Double> = .zero) -> AnyTransition {
        .modifier(
            active: OffsetEffect(offset: active).ignoredByLayout(),
            identity: OffsetEffect(offset: identity).ignoredByLayout()
        )
    }
    
    static func offsetBinding(
        _ active: Binding<SIMD2<Double>>,
        identity: Binding<SIMD2<Double>> = .constant([0,0])
    ) -> AnyTransition {
        .modifier(
            active: OffsetBindingEffect(offset: active).ignoredByLayout(),
            identity: OffsetBindingEffect(offset: identity).ignoredByLayout()
        )
    }
    
}


struct OffsetEffect: GeometryEffect {
    
    var offset: SIMD2<Double>
    
    public typealias AnimatableData = SIMD2<Double>.AnimatableData
    
    public nonisolated var animatableData: AnimatableData {
        get { offset.animatableData }
        set { offset.animatableData = newValue }
    }
    
    nonisolated init(offset: SIMD2<Double> = .zero) {
        self.offset = offset
    }
     
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(.init(translationX: offset.x, y: offset.y))
    }
    
}


struct OffsetBindingEffect: GeometryEffect {
    
    @Binding var offset: SIMD2<Double>
    
    public typealias AnimatableData = SIMD2<Double>.AnimatableData
    
    public nonisolated var animatableData: AnimatableData {
        get { offset.animatableData }
        set { offset.animatableData = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(.init(translationX: offset.x, y: offset.y))
    }
    
}
