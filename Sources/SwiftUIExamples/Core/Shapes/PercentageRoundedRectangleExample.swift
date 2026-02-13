import SwiftUIKit


struct PercentageRoundedRectangleExample: View {
    
    @State private var size: Double = 250.0
    @State private var percentage: Double = 0.5
    @State private var axis: Axis = .horizontal
    
    public init() {}
    
    var body: some View {
        ExampleView(title: "Percentage Rounded Rectangle"){
            PercentageRoundedRectangle(
                axis,
                percentage: percentage
            )
            .fill(.tint)
            .frame(
                maxWidth: axis == .horizontal ? size : nil,
                maxHeight: axis == .vertical ? size : nil
            )
            .animation(.smooth, value: size)
            .animation(.smooth, value: axis)
            .padding()
        } parameters: {
            ExampleCell.Axis(axis: $axis.animation(.bouncy))
            
            HStack {
                ExampleSlider(value: .init($size, in: 20...700)){
                    Text("Size")
                }
                
                ExampleSlider(value: .init($percentage)){
                    Label("Percentage", systemImage: "percent")
                }
            }
        }
    }
}

#Preview("Percentage Rounded Rectangle") {
    PercentageRoundedRectangleExample()
        .previewSize()
}
