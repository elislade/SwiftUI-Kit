import SwiftUIKit


public struct LineShapeExample: View {
    
    @State private var thickness: Double = 6
    @State private var axis: Axis = .vertical
    @State private var anchor: UnitPoint = .center
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Line Shape") {
            LineShape(axis: axis, anchor: anchor)
                .stroke(lineWidth: thickness)
                .padding()
        } parameters: {
            ExampleCell.Axis(axis: $axis.animation(.bouncy))

            ExampleControlGroup {
                ExampleSlider(value: .init($thickness, in: 0.5...30)){
                    Text("Thickness")
                }
                
                ExampleSlider(value: .init($anchor[axis.inverse])){
                    Text("Anchor")
                }
            }
        }
    }
    
}


#Preview("Line Shape") {
    LineShapeExample()
        .previewSize()
}
