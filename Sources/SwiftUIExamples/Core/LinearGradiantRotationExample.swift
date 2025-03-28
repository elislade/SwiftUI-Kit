import SwiftUIKit


public struct LinearGradiantRotationExample : View {
    
    @State private var rotationDegrees: Double = .zero
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: nil) {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient.rotated(
                    Gradient(colors: [.purple, .yellow]),
                    angle: .degrees(rotationDegrees)
                ))
                .padding()
            
            ExampleTitle("Gradient Rotation")
            
            Slider(value: $rotationDegrees, in: 0...360)
                .exampleParameterCell()
            
        }
        #if os(watchOS)
        .ignoresSafeArea()
        #endif
    }
    
}


#Preview("LinearGradiant Rotation"){
    LinearGradiantRotationExample()
        .previewSize()
}
