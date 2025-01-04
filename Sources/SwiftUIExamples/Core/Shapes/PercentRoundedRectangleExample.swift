import SwiftUIKit


public struct PercentRoundedRectangleExample: View {
    
    @State private var size: Double = 250.0
    @State private var percentage: Double = 0.5
    @State private var axis: Axis = .horizontal
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Percent Rounded Rectangle"){
            PercentageRoundedRectangle(axis, percentage: percentage)
                .fill(.tint)
                .frame(
                    width: axis == .horizontal ? size : nil,
                    height: axis == .vertical ? size : nil
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
                    
                    Text(percentage, format: .number.rounded(increment: 0.01))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $size, in: 20...700)
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Percentage")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(percentage, format: .number.rounded(increment: 0.01))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $percentage)
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $axis){
                    Text("Horizontal").tag(Axis.horizontal)
                    Text("Vertical").tag(Axis.vertical)
                }
            }
            .padding()
        }
    }
}

#Preview("Percent Rounded Rectangle") {
    PercentRoundedRectangleExample()
        .previewSize()
}
