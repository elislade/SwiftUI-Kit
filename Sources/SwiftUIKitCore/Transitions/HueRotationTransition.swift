import SwiftUI


public extension AnyTransition {
    
    static func hue(rotation: Angle = .degrees(360)) -> AnyTransition {
        .modifier(
            active: HueRotationModifier(angle: rotation),
            identity: HueRotationModifier()
        )
    }
    
}


struct HueRotationModifier: ViewModifier, Hashable {
    
    let angle: Angle
    
    nonisolated init(angle: Angle = .zero) {
        self.angle = angle
    }
    
    func body(content: Content) -> some View {
        content.hueRotation(angle)
    }
    
}
