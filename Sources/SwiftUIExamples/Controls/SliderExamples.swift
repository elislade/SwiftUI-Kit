import SwiftUIKit


public struct SliderExamples: View {
    
    @State private var value: Double = 0
    
    @State private var disable = false
    @State private var controlSize = ControlSize.regular
    @State private var direction = LayoutDirection.leftToRight
    @State private var directionSuggestion = LayoutDirectionSuggestion.useSystemDefault
    @State private var controlRoundness: Double = 1
    @State private var animation: Animation?
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Slider"){
            AxisStack(directionSuggestion.useVertical ? .horizontal : .vertical) {
                ExampleCard(title: "SwiftUI Slider") {
                    SwiftUI.Slider(value: $value)
                }
                
                ExampleCard(title: "SwiftUIKit Slider") {
                    Slider(value: $value.animation(animation))
                }
            }
            .padding()
            .environment(\.layoutDirection, direction)
            .environment(\.layoutDirectionSuggestion, directionSuggestion)
            .controlRoundness(controlRoundness)
            .disabled(disable)
        } parameters: {
            HStack {
                Text("Test Animation")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Animate") {
                    animation = .bouncy.speed(0.6)
                    //withAnimation(.bouncy){
                        value = .random(in: 0...1)
                   // }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        animation = nil
                    }
                }
            }
            .exampleParameterCell()
            
            Toggle(isOn: $disable){
                Text("Disable")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirectionSuggestion(value: $directionSuggestion)
            
            ExampleCell.LayoutDirection(value: $direction)

            ExampleCell.ControlRoundness(value: $controlRoundness)
        }
    }
    
}


#Preview("Slider") {
    SliderExamples()
        .previewSize()
}
