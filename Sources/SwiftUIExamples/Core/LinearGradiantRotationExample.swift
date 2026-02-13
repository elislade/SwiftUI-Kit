import SwiftUIKit


public struct LinearGradiantRotationExample : View {
    
    @State private var rotation = Measurement(value: 0, unit: UnitAngle.degrees)
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Linear Gradient Rotation") {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient.rotated(
                    Gradient(colors: [.purple, .yellow]),
                    angle: .degrees(rotation.value)
                ))
                .ignoresSafeArea()
        } parameters: {
            ExampleSlider(
                value: $rotation,
                in: 0...360,
                format: .parse(.degrees)
            ){
                Text("Degrees")
            }
        }
    }
    
}


#Preview("LinearGradiant Rotation"){
    LinearGradiantRotationExample()
        .previewSize()
}
