import SwiftUIKit


struct LinearGradiantRotationExample : View {
    
    @State private var rotationDegrees: Double = .zero
    
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient.rotated(
                    Gradient(colors: [.purple, .yellow]),
                    angle: .degrees(rotationDegrees)
                ))
            
            ExampleTitle("Gradient Rotation")
            Slider(value: $rotationDegrees, in: 0...360)
            
        }
        .padding()
    }
    
}


#Preview("LinearGradiant Rotation"){
    LinearGradiantRotationExample()
}
