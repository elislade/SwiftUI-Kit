import SwiftUIKit


struct StepperExamples: View {
    
    @State private var value = 0.0
    @State private var disable = false
    @State private var controlRoundness: Double = 1
    @State private var controlSize = ControlSize.regular
    @State private var direction = LayoutDirection.leftToRight
    @State private var directionSuggestion = LayoutDirectionSuggestion.useSystemDefault
    
    var body: some View {
        ExampleView(title: "Stepper"){
            VStack(spacing: 10){
                Text(value, format: .number.rounded(increment: 1))
                    .font(.largeTitle.bold().monospacedDigit())
                    .contentTransitionNumericText()
                
                HStack {
                    ExampleCard(title: "SwiftUI") {
                        SwiftUI.Stepper("", value: $value)
                    }
                    .frame(maxWidth: .infinity)

                    ExampleCard(title: "SwiftUIKit"){
                        Stepper(value: $value)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .labelsHidden()
            .animation(.bouncy, value: value)
            .environment(\.layoutDirection, direction)
            .environment(\.layoutDirectionSuggestion, directionSuggestion)
            .disabled(disable)
            .controlSize(controlSize)
            .controlRoundness(controlRoundness)
        } parameters: {
            Toggle(isOn: $disable){
                Text("Disable")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.LayoutDirectionSuggestion(value: $directionSuggestion)
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $direction)
            
            Divider() 
            
            ExampleCell.ControlSize(value: $controlSize)
            
            Divider()
            
            ExampleCell.ControlRoundness(value: $controlRoundness)
            
        }
    }
    
}


#Preview("Stepper") {
    StepperExamples()
}


