import SwiftUI


public extension AnyTransition {
    
    static func blur(radius: Double = 40, opaque: Bool = false) -> AnyTransition {
        .modifier(
            active: BlurModifier(radius: radius, opaque: opaque),
            identity: BlurModifier(opaque: opaque)
        )
    }
    
}


struct BlurModifier: ViewModifier, Hashable {
    
    let radius: Double
    let opaque: Bool
    
    nonisolated init(radius: Double = 0, opaque: Bool = false) {
        self.radius = radius
        self.opaque = opaque
    }
    
    func body(content: Content) -> some View {
        content
            .blur(radius: radius, opaque: opaque)
    }
    
}

