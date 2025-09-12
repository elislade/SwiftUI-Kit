import SwiftUI


public struct EdgeHighlightMaterial<Shape: InsettableShape>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.reduceMotion) private var reduceMotion
    @State private var center: UnitPoint = .topLeading
    
    private var isDark : Bool { colorScheme == .dark }
    
    let shape: Shape
    
    public init(_ shape: Shape) {
        self.shape = shape
    }
    
    // TODO: Add Device Motion Tracking
    public var body: some View {
        AngularGradient(
            stops: [
                .init(color: .clear, location: 0.01),
                .init(color: .white.opacity(isDark ? 0.8 : 1), location: 0.2),
                .init(color: .clear, location: 0.5),
                .init(color: .white.opacity(isDark ? 0.8 : 1), location: 0.65),
                .init(color: .clear, location: 0.9)
            ],
            center: center
        )
        .animation(.smooth.speed(0.5), value: center)
        .zIndex(1)
        .opacity(isDark ? 0.6 : 1)
        .mask {
            shape
                .inset(by: 0.5)
                .strokeBorder()
        }
        .onAppear{
            if !reduceMotion {
                center = .init(x: 0.9, y: 0.1)
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
//        .onContinuousHoverPolyfill{ phase in
//            switch phase {
//            case .active(let p):
//                center = .init(
//                    x: p.x / proxy.size.width,
//                    y: p.y / proxy.size.height
//                )
//            case .ended:
//                center = .center
//            }
//        }
    }
    
}

