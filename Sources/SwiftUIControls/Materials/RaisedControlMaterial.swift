import SwiftUI
import SwiftUIKitCore


public struct RaisedControlMaterial<Shape: InsettableShape> : View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactionGranularity) private var granularity
    
    let shape: Shape
    let isPressed: Bool
    
    public init(_ shape: Shape, isPressed: Bool = false) {
        self.shape = shape
        self.isPressed = isPressed
    }
    
    public var body: some View {
        ZStack {
            shape.fill(.linearGradient(
                colors: [Color(white: 0.9), .white],
                startPoint: .top,
                endPoint: .bottom
            ))
            .opacity(isPressed ? 0.9 : 1)
        }
        .overlay {
            shape.strokeBorder(Color.white)
        }
        .clipShape(shape)
        .background{
            shape
                .fill(.black)
                .opacity(0.2)
                .blur(radius: 2)
                .offset(y: 2)
        }
    }
}


public extension RaisedControlMaterial where Shape == Rectangle {
    
    init(isPressed: Bool = false){
        self.init(Rectangle(), isPressed: isPressed)
    }
    
}

#Preview {
    HStack {
        RaisedControlMaterial(Circle())
        RaisedControlMaterialSecondary(Circle())
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}


public struct RaisedControlMaterialSecondary<Shape: InsettableShape> : View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.interactionGranularity) private var granularity
    
    let shape: Shape
    let isPressed: Bool
    
    public init(_ shape: Shape, isPressed: Bool = false) {
        self.shape = shape
        self.isPressed = isPressed
    }
    
    public var body: some View {
        ZStack {
//            AnyShapeStyle(
//                .linearGradient(colors: [Color(white: 0.9), .white], startPoint: .top, endPoint: .bottom)
//                .shadow(.inner(color: .white, radius: 0, y: 1))
//            )

            shape
                .fill(Color(white: colorScheme == .light ? 0.99 : 0.88))
                .shadow(
                    color: .black.opacity(colorScheme == .light ? 0.2 : 0.4),
                    radius: 1,
                    y: 1
                )
                .shadow(
                    color: .black.opacity(colorScheme == .light ? 0.2 : 0.4),
                    radius: 10.0 - (8 * granularity),
                    y: 10.0 - (8 * granularity)
                )

            shape
                .fill(.secondary)
                .opacity(isPressed ? colorScheme == .light ? 0.2 : 0.8 : 0)

            shape
                .inset(by: -0.5)
                .strokeBorder(lineWidth: 0.5)
                .opacity(0.1)

            shape
                .strokeBorder(lineWidth: 0.5)
                .foregroundStyle(.linearGradient(
                    colors: [.white, .clear],
                    startPoint: .top, endPoint: .init(x: 0.5, y: 0.1)
                ))
                .opacity(colorScheme == .light ? 1 : 0.3)
                .clipShape(shape)
        }
        .clipShape(shape)
        .background{
            shape
                .fill(.black)
                .opacity(0.2)
                .blur(radius: 2)
                .offset(y: 2)
        }
    }
}
