import SwiftUI


public extension View {
    
    nonisolated func hinge(degrees: Double, edge: Edge) -> some View {
        modifier(HingeModifier(degrees: degrees, edge: edge))
    }
    
}


public extension AnyTransition {
    
    static func hinge(_ edge: Edge, movesAway: Bool = false) -> AnyTransition {
        modifier(
            active: HingeModifier(degrees: movesAway ? -90 : 90, edge: edge),
            identity: HingeModifier(edge: edge)
        )
    }
    
}
