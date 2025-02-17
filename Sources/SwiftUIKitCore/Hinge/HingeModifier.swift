import SwiftUI

struct HingeModifier: ViewModifier {
    
    let degrees: Double
    let edge: Edge
    
    nonisolated init(degrees: Double = 0, edge: Edge = .top) {
        self.degrees = degrees
        self.edge = edge
    }
    
    private var yA: CGFloat {
        edge == .bottom ? 1 : edge == .top ? 0 : 0.5
    }
    
    private var xA: CGFloat {
        edge == .leading ? 0 : edge == .trailing ? 1 : 0.5
    }
    
    private var axis: (CGFloat, CGFloat, CGFloat) {
        edge == .top || edge == .bottom ? (1,0,0) : (0,1,0)
    }
    
    private var normalizedDeg: Double {
        edge == .leading || edge == .bottom ? degrees * -1 : degrees
    }
    
    func body(content: Content) -> some View {
        content.rotation3DEffect(
            Angle(degrees: normalizedDeg),
            axis: axis,
            anchor: UnitPoint(x: xA, y: yA),
            perspective: -0.5
        )
    }
}
