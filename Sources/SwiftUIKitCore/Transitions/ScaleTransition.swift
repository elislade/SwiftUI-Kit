import SwiftUI


extension AnyTransition {
    
    public static func scale(_ amount: Double = 0, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleEffect([amount, amount], anchor: anchor).ignoredByLayout(),
            identity: ScaleEffect([1,1], anchor: anchor).ignoredByLayout()
        )
    }
    
    public static func scale(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleEffect([x,y], anchor: anchor).ignoredByLayout(),
            identity: ScaleEffect([1,1], anchor: anchor).ignoredByLayout()
        )
    }
    
    public static func scale(_ active: SIMD2<Double>, identity: SIMD2<Double> = [1,1], anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleEffect(active, anchor: anchor).ignoredByLayout(),
            identity: ScaleEffect(identity, anchor: anchor).ignoredByLayout()
        )
    }
    
    public static func scaleBinding(_ active: Binding<SIMD2<Double>>, identity: Binding<SIMD2<Double>> = .constant([1,1]), anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleBindingEffect(active, anchor: anchor).ignoredByLayout(),
            identity: ScaleBindingEffect(identity, anchor: anchor).ignoredByLayout()
        )
    }
    
}


struct ScaleEffect: GeometryEffect {
    
    var scale: SIMD2<Double>
    let anchor: UnitPoint
    
    typealias AnimatableData = SIMD2<Double>.AnimatableData
    
    nonisolated public var animatableData: AnimatableData {
        get { scale.animatableData }
        set { scale.animatableData = newValue }
    }
    
    nonisolated init(_ scale: SIMD2<Double>, anchor: UnitPoint = .center) {
        self.scale = scale
        self.anchor = anchor
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let safe = scale.moveAwayFromZero(to: 0.0001)
        return .init(
            .init(scaleX: safe.x, y: safe.y)
            .concatenating(.init(
                translationX: (safe.x - 1) * (-size.width * (anchor.x)),
                y: (safe.y - 1) * (-size.height * (anchor.y))
            ))
        )
    }
    
}


struct ScaleBindingEffect: GeometryEffect {
    
    @Binding var scale: SIMD2<Double>
    let anchor: UnitPoint
    
    var animatableData: SIMD2<Double>.AnimatableData {
        get { scale.animatableData }
        set { scale.animatableData = newValue }
    }
    
    nonisolated init(_ scale: Binding<SIMD2<Double>>, anchor: UnitPoint = .center) {
        self._scale = scale
        self.anchor = anchor
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let safe = scale.moveAwayFromZero(to: 0.0001)
        return .init(
            .init(scaleX: safe.x, y: safe.y)
            .concatenating(.init(
                translationX: (safe.x - 1) * (-size.width * (anchor.x)),
                y: (safe.y - 1) * (-size.height * (anchor.y))
            ))
        )
    }
    
}



extension View {
    
    /// Supliments SwiftUIs standard Scale modifier because the base scale GeometryEffect is not publicly available to add the `ignoredByLayout()` version.
    /// This scales the view after all geometry calculations are done right before rendering while the standard version scales before the Geometry calculations are done.
    /// - Note: Use this if you don't wan't safeArea calculation reevaluated while the scale changes.
    /// - Warning: Hit-testing and `matchGeometryEffect` will not match this views bounds as this scaling happens after those calculations.
    /// - Parameters:
    ///    - scale: The amount to offset the view.
    ///    - anchor: `UnitPoint` from where to scale from. Defaults to center (0.5, 0.5).
    /// - Returns: A modified view.
    nonisolated public func scaleIgnoredByLayout(_ scale: SIMD2<Double>, anchor: UnitPoint = .center) -> some View {
        modifier(ScaleEffect(scale, anchor: anchor).ignoredByLayout())
    }
    
    nonisolated public func scaleIgnoredByLayout(uniform scale: Double, anchor: UnitPoint = .center) -> some View {
        modifier(ScaleEffect([scale, scale], anchor: anchor).ignoredByLayout())
    }
    
}
