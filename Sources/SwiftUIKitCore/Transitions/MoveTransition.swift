import SwiftUI


extension AnyTransition {
    
    nonisolated public static func moveEdge(_ edge: Edge) -> AnyTransition {
        .modifier(
            active: MoveEdgeEffect(edge: edge, progress: 1),
            identity: MoveEdgeEffect(edge: edge, progress: 0)
        )
    }
    
    nonisolated public static func moveEdgeIgnoredByLayout(_ edge: Edge) -> AnyTransition {
        .modifier(
            active: MoveEdgeEffect(edge: edge, progress: 1).ignoredByLayout(),
            identity: MoveEdgeEffect(edge: edge, progress: 0).ignoredByLayout()
        )
    }
    
}


struct MoveEdgeEffect: GeometryEffect, Animatable {
    
    let edge: Edge
    var progress: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(.init(
            translationX: edge == .leading ? -size.width * progress : edge == .trailing ? size.width * progress : 0,
            y: edge == .bottom ? size.height * progress : edge == .top ? -size.height * progress : 0
        ))
    }
    
}


extension View {
    
    nonisolated public func move(edge: Edge, progress: Double) -> some View {
        modifier(MoveEdgeEffect(edge: edge, progress: progress).ignoredByLayout())
    }
    
}
