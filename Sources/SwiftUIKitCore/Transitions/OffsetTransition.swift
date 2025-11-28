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


extension View {
    
    /// Supliments SwiftUIs standard Offset modifier because the base offset GeometryEffect is not publicly available to add the `ignoredByLayout()` version.
    /// This offsets the view after all geometry calculations are done right before rendering while the standard version offsets before the Geometry calculations are done.
    /// - Note: Use this if you don't wan't safeArea calculation reevaluated while the offset changes.
    /// - Parameter offset: The amount to offset the view.
    /// - Returns: A modified view.
    nonisolated public func offsetIgnoredByLayout(_ offset: SIMD2<Double>) -> some View {
        modifier(OffsetEffect(offset: offset).ignoredByLayout())
    }
    
}
