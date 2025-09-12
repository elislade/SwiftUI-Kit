import SwiftUI


public struct InteractionGlowMaterial<Shape: InsettableShape>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var relativeLocation: CGPoint?
    
    let shape: Shape
    
    public init(_ shape: Shape) {
        self.shape = shape
    }
    
    public var body: some View {
        Color.clear.background {
            GeometryReader { proxy in
                let global = proxy.frame(in: .global)
                Color.clear.onWindowDrag{ evt in
                    guard
                        evt.phase != .ended,
                        let location = evt.locations.first
                    else {
                        relativeLocation = nil
                        return
                    }
                    
                    relativeLocation = .init(
                        x: location.x - global.minX,
                        y: location.y - global.minY
                    )
                }
            }
        }
        .overlay {
            ZStack {
                if let relativeLocation {
                    Circle()
                        .fill(.white)
                        .frame(width: 100, height: 100)
                        .position(.zero)
                        .offset(x: relativeLocation.x, y: relativeLocation.y - 10)
                        .blur(radius: 60)
                        .animation(.smooth.delay(0.2), value: relativeLocation)
                        .opacity(colorScheme == .dark ? 0.8 : 1)
                        .blendMode(.overlay)
                        .transition(.opacity)
                }
            }
            .animation(.smooth, value: relativeLocation == nil)
        }
        .environment(\.layoutDirection, .leftToRight)
        .drawingGroup()
        .clipShape(shape)
    }
    
}

#Preview {
    InteractionGlowMaterial(.circle)
        .background{
            Circle().opacity(0.1)
        }
        .frame(width: 200, height: 200)
        .offset(y: 200)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.1))
}
