import SwiftUI


public extension AnyTransition {
    
    static func scale(_ amount: Double = 0, anchor: UnitPoint = .center) -> AnyTransition {
        .scale(scale: amount, anchor: anchor)
    }
    
    static func scale(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleModifier(x: x, y: y, anchor: anchor),
            identity: ScaleModifier(anchor: anchor)
        )
    }
    
}


struct ScaleModifier: ViewModifier, Hashable {
    
    let x: Double
    let y: Double
    let anchor: UnitPoint
    
    nonisolated init(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) {
        self.x = x
        self.y = y
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content.scaleEffect(x: x, y: y, anchor: anchor)
    }
    
}
