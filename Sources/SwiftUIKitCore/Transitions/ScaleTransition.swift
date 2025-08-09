import SwiftUI


public extension AnyTransition {
    
    static func scale(_ amount: Double = 0, anchor: UnitPoint = .center) -> AnyTransition {
        .scale(scale: amount, anchor: anchor)
    }
    
    static func scale(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleModifier([x,y], anchor: anchor),
            identity: ScaleModifier([1,1], anchor: anchor)
        )
    }
    
    static func scale(_ active: SIMD2<Double>, identity: SIMD2<Double> = [1,1], anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleModifier(active, anchor: anchor),
            identity: ScaleModifier(identity, anchor: anchor)
        )
    }
    
}


struct ScaleModifier: ViewModifier {
    
    var scale: SIMD2<Double>
    let anchor: UnitPoint
    
    nonisolated init(_ scale: SIMD2<Double>, anchor: UnitPoint = .center) {
        self.scale = scale
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content.scaleEffect(x: scale.x, y: scale.y, anchor: anchor)
    }
    
}
