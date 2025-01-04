import SwiftUIKit


public struct AsymmetricRoundedRectangleExamples: View {
    
    @State private var inset: Double = 16
    @State private var values = RadiusValues(30)
    
    private let radiusRange = 0.0...180.0
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Asymmetric Rounded Rectangle"){
            ZStack {
                AsymmetricRoundedRectangle(values: values)
                    .fill(.tint)
                    .opacity(0.5)
                
                AsymmetricRoundedRectangle(values: values)
                    .inset(by: inset)
                    .fill(.tint)
            }
            .padding()
        } parameters: {
            VStack {
                HStack {
                    Text("Inset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(inset, format: .number.rounded(increment: 0.1))
                        .font(.exampleParameterValue)
                }
                Slider(value: $inset, in: 0...50)
            }
            .padding()
            
            Divider()
            
            ExampleSection("Radius", isExpanded: true){
                HStack {
                    Text("Random")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Button("Animate"){
                        values.topLeft = .random(in: radiusRange)
                        values.topRight = .random(in: radiusRange)
                        values.bottomLeft = .random(in: radiusRange)
                        values.bottomRight = .random(in: radiusRange)
                    }
                }
                .padding()
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Top Left")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.topLeft, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.topLeft, in: radiusRange)
                }
                .padding()
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Top Right")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.topRight, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.topRight, in: radiusRange)
                }
                .padding()
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Bottom Left")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.bottomLeft, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.bottomLeft, in: radiusRange)
                }
                .padding()
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Bottom Right")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.bottomRight, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.bottomRight, in: radiusRange)
                }
                .padding()
                
                Divider()
            }
        }
        .animation(.interactiveSpring, value: values)
    }
    
}


#Preview("Asymmetric Rounded Rectangle") {
    AsymmetricRoundedRectangleExamples()
        .previewSize()
}
