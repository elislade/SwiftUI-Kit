import SwiftUI


public struct EdgeHighlightSmallMaterial<Shape: InsettableShape>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.reduceMotion) private var reduceMotion
    @State private var center: UnitPoint = .topLeading
    @State private var showHighlight = false
    
    private var isDark : Bool { colorScheme == .dark }
    
    let shape: Shape
    
    public init(_ shape: Shape) {
        self.shape = shape
    }
    
    public var body: some View {
        shape.strokeBorder(
            LinearGradient(
                colors: [.white, .white.opacity(0.1), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            style: .init()
        )
        .opacity(isDark ? 0.25 : 1)
        .overlay {
            shape
                .trim(to: showHighlight ? 1 : 0)
                .stroke(
                AngularGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white, location: 1)
                    ],
                    center: .center
                ),
                style: .init()
            )
            .opacity(showHighlight ? 0 : 1)
            .animation(.smooth.speed(0.5), value: center)
        }
        .onAppear{
            if !reduceMotion {
                center = .init(x: 0.9, y: 0.1)
                showHighlight = true
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }
    
}
