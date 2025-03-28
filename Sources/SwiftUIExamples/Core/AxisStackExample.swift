import SwiftUIKit


public struct AxisStackExampleView : View {
    
    @State private var axis: Axis = .vertical
    @State private var alignment: Alignment = .center
    @State private var spacing: Double = 0
    @State private var items: [Color] = [.random, .random, .random, .random]
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Axis Stack"){
            AxisStack(axis, alignment: alignment, spacing: spacing){
                ForEach(items.indices, id: \.self){ i in
                    items[i]
                }
            }
            .animation(.smooth, value: axis)
        } parameters: {
            SegmentedPicker(selection: $axis.animation(.smooth), items: Axis.allCases){
                Text("\($0)".capitalized)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Spacing")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(spacing, format: .increment(0.1))
                        .font(.exampleParameterValue)
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
