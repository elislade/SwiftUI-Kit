import SwiftUI


public extension AnyTransition {
    
    static func rotation(angle: Angle = .degrees(180), anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: RotationModifier(angle: angle, anchor: anchor),
            identity: RotationModifier(anchor: anchor)
        )
    }
    
}


struct RotationModifier: ViewModifier, Hashable {
    
    let angle: Angle
    let anchor: UnitPoint
    
    nonisolated init(angle: Angle = .zero, anchor: UnitPoint = .center) {
        self.angle = angle
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content.rotationEffect(angle, anchor: anchor)
    }
    
}
