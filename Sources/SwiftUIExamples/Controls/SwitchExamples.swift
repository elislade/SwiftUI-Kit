import SwiftUIKit


struct SwitchExamples : View {

    @State private var isOn = true
    @State private var disable = false
    @State private var direction = LayoutDirection.leftToRight
    @State private var directionSuggestion = LayoutDirectionSuggestion.useSystemDefault
    @State private var accessibleOnOffLabelsEnabled = false
    @State private var useCustomLabels = false
    @State private var controlRoundness: Double = 1
    @State private var controlSize = ControlSize.regular
    
    private var offLabel: some View {
        Image(systemName: "car.fill")
            .resizable()
            .scaledToFit()
            .opacity(0.5)
    }
    
    private var onLabel: some View {
        Image(systemName: "dog.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.white)
    }
    
    var body: some View {
        ExampleView(title: "Switch"){
            HStack {
                ExampleCard(title: "SwiftUI") {
                    Toggle("", isOn: $isOn)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                
                ExampleCard(title: "SwiftUIKit") {
                    if useCustomLabels {
                        Switch(isOn: $isOn){ offLabel } onLabel: {
                            onLabel
                        }
                    } else {
                        Switch(isOn: $isOn)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .controlRoundness(controlRoundness)
            .controlSize(controlSize)
            .environment(\.layoutDirection, direction)
            .environment(\.layoutDirectionSuggestion, directionSuggestion)
            .environment(\.isOnOffSwitchLabelsEnabled, accessibleOnOffLabelsEnabled)
            .disabled(disable)
            .animation(.bouncy, value: isOn)
        } parameters: {
            Toggle(isOn: $disable){
                Text("Disable")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.ControlRoundness(value: $controlRoundness)
            
            Divider()
  
            Toggle(isOn: $accessibleOnOffLabelsEnabled){
                Text("Accessible Labels")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()

            Toggle(isOn: $useCustomLabels){
                Text("Use Custom Labels")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.ControlSize(value: $controlSize)
            
            Divider()
            
            ExampleCell.LayoutDirectionSuggestion(value: $directionSuggestion)
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $direction)
            
            Divider()
        }
    }
    
}


#Preview("Switch") {
    SwitchExamples()
}
