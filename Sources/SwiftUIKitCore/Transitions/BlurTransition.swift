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


@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct BlurTransition: Transition {
    
    let radius: Double
    let opaque: Bool
    
    public nonisolated init(radius: Double = 0, opaque: Bool = false) {
        self.radius = radius
        self.opaque = opaque
    }
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .blur(radius: phase.isIdentity ? 0 : radius, opaque: opaque)
    }
    
}


@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension Transition where Self == BlurTransition {
    
    static func blur(radius: Double = 40, opaque: Bool = false) -> Self {
        BlurTransition(radius: radius, opaque: opaque)
    }
    
}
