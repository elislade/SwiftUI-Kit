import SwiftUIKit


struct PercentageRoundedRectangleExample: View {
    
    @State private var size: Double = 250.0
    @State private var percentage: Double = 0.5
    @State private var axis: Axis = .horizontal
    
    public init() {}
    
    var body: some View {
        ExampleView(title: "Percentage Rounded Rectangle"){
            PercentageRoundedRectangle(axis, percentage: percentage)
                .fill(.tint)
                .frame(
                    maxWidth: axis == .horizontal ? size : nil,
                    maxHeight: axis == .vertical ? size : nil
                )
                .animation(.smooth, value: size)
                .animation(.smooth, value: axis)
                .padding()
        } parameters: {
            VStack {
                HStack {
                    Text("Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(size, format: .increment(0.01))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $size, in: 20...700)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Percentage")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(percentage, format: .increment(0.01))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $percentage)
            }
            .exampleParameterCell()
            
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $axis.animation(.bouncy), items: Axis.allCases){
                    Text("\($0)".capitalized)
                }
                .frame(maxWidth: 200)
            }
            .exampleParameterCell()
        }
    }
}

#Preview("Percentage Rounded Rectangle") {
    PercentageRoundedRectangleExample()
        .previewSize()
}
