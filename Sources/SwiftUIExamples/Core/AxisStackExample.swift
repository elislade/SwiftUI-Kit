import SwiftUIKit


public struct AxisStackExampleView : View {
    
    @State private var axis: Axis = .vertical
    @State private var alignment: Alignment = .center
    @State private var spacing: Double = 0
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Axis Stack"){
            AxisStack(axis, alignment: alignment, spacing: spacing){
                ForEach(0..<5, id: \.self){ i in
                    Rectangle()
                        .fill(.tint)
                        .opacity(Double(i + 1) / 5)
                        .background(.background, in: .rect)
                        .animationDelay(Double(i) * 0.1)
                }
            }
            .ignoresSafeArea()
            .animation(.bouncy, value: axis)
        } parameters: {
            ExampleCell.Axis(axis: $axis.animation(.smooth))
                .exampleParameterCell()
            
            VStack {
                LabeledContent {
                    Text(spacing, format: .increment(0.1))
                        .font(.exampleParameterValue)
                } label: {
                    Text("Spacing")
                        .font(.exampleParameterTitle)
                }
                
                Slider(value: $spacing, in: 0...30)
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview("Axis Stack") {
    AxisStackExampleView()
        .previewSize()
}
