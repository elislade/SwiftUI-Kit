import SwiftUIKit


public struct LinearGradiantRotationExample : View {
    
    @State private var rotationDegrees: Double = .zero
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Linear Gradient Rotation") {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient.rotated(
                    Gradient(colors: [.purple, .yellow]),
                    angle: .degrees(rotationDegrees)
                ))
                .ignoresSafeArea()
        } parameters: {
            Slider(value: $rotationDegrees, in: 0...360)
                .exampleParameterCell()
        }
    }
    
}


#Preview("LinearGradiant Rotation"){
    LinearGradiantRotationExample()
        .previewSize()
}
