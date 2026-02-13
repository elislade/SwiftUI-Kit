import SwiftUIKit


public struct StepperExamples: View {
    
    @State private var value = 0.0
    @State private var disable = false
    @State private var controlRoundness: Double = 1
    @State private var controlSize = ControlSize.regular
    @State private var direction = LayoutDirection.leftToRight
    @State private var directionSuggestion = LayoutDirectionSuggestion.useSystemDefault
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Stepper"){
            VStack(spacing: 10){
                Text(value, format: .increment(1))
                    .font(.largeTitle.bold().monospacedDigit())
                    .contentTransitionNumericText()
                    .minimumScaleFactor(0.5)
                
                HStack {
                    #if !os(tvOS) && !os(watchOS)
                    ExampleCard(title: "SwiftUI") {
                        VStack {
                            SwiftUI.Stepper("", value: $value, in: -1...4)
                            SwiftUI.Stepper("", onIncrement: {  value += 1 }, onDecrement: nil)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    #endif
                    
                    ExampleCard(title: "SwiftUIKit"){
                        VStack {
                            Stepper(value: $value, in: -1...4)
                            Stepper(onIncrement: { value += 1 }, onDecrement: nil)
                        }
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
            ExampleSection(isExpanded: true){
                Toggle(isOn: $disable){
                    Text("Disable")
                }
                
                ExampleCell.ControlRoundness(value: $controlRoundness)
                
                HStack {
                    ExampleCell.ControlSize(value: $controlSize)
                        .fixedSize()
                    
                    ExampleCell.LayoutDirectionSuggestion(value: $directionSuggestion)
                }
                
                ExampleCell.LayoutDirection(value: $direction)
            } label: {
                Text("Parameters")
            }
        }
    }
    
}


#Preview("Stepper") {
    StepperExamples()
        .previewSize()
}


