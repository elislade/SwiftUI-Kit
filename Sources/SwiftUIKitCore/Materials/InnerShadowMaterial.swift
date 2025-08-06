import SwiftUI


public struct InnerShadowMaterial<Shape: InsettableShape, Fill: ShapeStyle>: View {
    
    let shape: Shape
    let fill: Fill
    let radius: Double
    let x: Double
    let y: Double
    
    public init(
        _ shape: Shape,
        fill: Fill,
        radius: Double,
        x: Double = 0,
        y: Double = 0
    ) {
        self.shape = shape
        self.fill = fill
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    public init(
        _ shape: Shape,
        fill: Fill,
        radius: Double,
        angle: Angle = .degrees(45),
        amount: Double = 0
    ) {
        self.shape = shape
        self.fill = fill
        self.radius = radius
        self.x = cos(angle.radians) * amount
        self.y = sin(angle.radians) * amount
    }
    
    
    public var body: some View {
        ZStack {
            shape.fill(fill)
             
            shape
                .offset(x: x, y: y)
                .fill(.black)
                .blur(radius: radius)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
    
}

extension InnerShadowMaterial where Fill == Color {
    
    public init(
        _ shape: Shape,
        radius: Double,
        x: Double = 0,
        y: Double = 0
    ) {
        self.init(
            shape,
            fill: Color.primary.opacity(0.5),
            radius: radius,
            x: x, y: y
        )
    }
    
    public init(
        _ shape: Shape,
        radius: Double,
        angle: Angle,
        amount: Double = 0
    ) {
        self.init(
            shape,
            fill: Color.primary.opacity(0.5),
            radius: radius,
            angle: angle,
            amount: amount
        )
    }
    
}
