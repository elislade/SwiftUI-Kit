import SwiftUIKit


public struct ToolTipExamples: View {
        
    @State private var isPresented = false
    @State private var axis: Axis = .vertical
    @State private var position: CGPoint = .zero
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Tool Tip"){
            Color.clear.overlay{
                Image(systemName: "car")
                    .font(.title)
                    .toolTip(axis: axis, isPresented: $isPresented){
                        Text("Car go vroom vroom! 🚗")
                            .font(.caption)
                            .padding(5)
                    }
                    .offset(position)
                    .gesture(DragGesture().onChanged{
                        position = $0.location
                    })
            }
            .animation(.bouncy, value: isPresented)
            .toolTipContext()
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Presented")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleCell.Axis(axis: $axis.animation(.bouncy))
                .exampleParameterCell()
        }
    }
    
}


#Preview {
    ToolTipExamples()
        .previewSize()
}
