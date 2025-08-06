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
                
                AsymmetricRoundedRectangle(values: values)
                    .inset(by: inset)
                    .strokeBorder(.primary, style: .init(lineWidth: 3, lineCap: .round, dash: [4,6]))
            }
            .padding()
        } parameters: {
            VStack {
                HStack {
                    Text("Inset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(inset, format: .increment(0.1))
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
                        withAnimation(.smooth){
                            values.topLeft = .random(in: radiusRange)
                            values.topRight = .random(in: radiusRange)
                            values.bottomLeft = .random(in: radiusRange)
                            values.bottomRight = .random(in: radiusRange)
                        }
                    }
                }
                .exampleParameterCell()
                
                VStack {
                    HStack {
                        Text("Top Left")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.topLeft, format: .increment(0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.topLeft, in: radiusRange)
                }
                .exampleParameterCell()
                
                VStack {
                    HStack {
                        Text("Top Right")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.topRight, format: .increment(0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.topRight, in: radiusRange)
                }
                .exampleParameterCell()
                
                VStack {
                    HStack {
                        Text("Bottom Left")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.bottomLeft, format: .increment(0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.bottomLeft, in: radiusRange)
                }
                .exampleParameterCell()
                
                VStack {
                    HStack {
                        Text("Bottom Right")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(values.bottomRight, format: .increment(0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $values.bottomRight, in: radiusRange)
                }
                .exampleParameterCell()
            }
        }
    }
    
}


#Preview("Asymmetric Rounded Rectangle") {
    AsymmetricRoundedRectangleExamples()
        .previewSize()
}
