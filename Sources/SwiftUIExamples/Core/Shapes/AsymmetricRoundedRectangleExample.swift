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
                    .strokeBorder(
                        .primary,
                        style: .init(lineWidth: 3, lineCap: .round, dash: [4,6])
                    )
            }
            .padding()
            .frame(maxWidth: 600, maxHeight: 600)
        } parameters: {
            ExampleSlider(value: .init($inset, in: 0...50)){
                Text("Inset")
            }
            
            ExampleSection("Radius", isExpanded: true){
                Button{
                    withAnimation(.smooth){
                        values.topLeft = .random(in: radiusRange)
                        values.topRight = .random(in: radiusRange)
                        values.bottomLeft = .random(in: radiusRange)
                        values.bottomRight = .random(in: radiusRange)
                    }
                } label: {
                    Label("Random", systemImage: "dice")
                        .frame(maxWidth: .infinity)
                }
                
                HStack {
                    ExampleSlider(value: .init($values.topLeft, in: radiusRange)){
                        Text("Top Left")
                    }
                    
                    ExampleSlider(value: .init($values.topRight, in: radiusRange)){
                        Text("Top Right")
                    }
                }
                
                HStack {
                    ExampleSlider(value: .init($values.bottomLeft, in: radiusRange)){
                        Text("Bottom Left")
                    }
                    
                    ExampleSlider(value: .init($values.bottomRight, in: radiusRange)){
                        Text("Bottom Right")
                    }
                }
            }
        }
    }
    
}


#Preview("Asymmetric Rounded Rectangle") {
    AsymmetricRoundedRectangleExamples()
        .previewSize()
}
