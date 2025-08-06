import SwiftUI


public struct EdgeHighlightMaterial<Shape: InsettableShape>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.reduceMotion) private var reduceMotion
    @State private var center: UnitPoint = .topLeading
    
    let shape: Shape
    
    public init(_ shape: Shape) {
        self.shape = shape
    }
    
    // TODO: Add Device Motion Tracking
    public var body: some View {
        GeometryReader { proxy in
            ZStack{
                shape
                    .inset(by: 0.5)
                    .strokeBorder(AngularGradient(
                        stops: [
                            .init(color: .clear, location: 0.01),
                            .init(color: .white.opacity(0.8), location: 0.2),
                            .init(color: .clear, location: 0.5),
                            .init(color: .white, location: 0.65),
                            .init(color: .clear, location: 0.9)
                        ],
                        center: center
                    ))
                    .zIndex(1)
                    .opacity(colorScheme == .dark ? 0.6 : 1)
            }
            .animation(.smooth.speed(0.5), value: center)
            .drawingGroup()
            .onContinuousHoverPolyfill{ phase in
                switch phase {
                case .active(let p):
                    center = .init(
                        x: p.x / proxy.size.width,
                        y: p.y / proxy.size.height
                    )
                case .ended:
                    center = .center
                }
            }
        }
        .task{
            if !reduceMotion {
                center = .init(x: 0.9, y: 0.1)
            }
        }
    }
    
}
