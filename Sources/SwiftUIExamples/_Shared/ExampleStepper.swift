import SwiftUIKit

struct ExampleStepper<Label: View>: View {
    
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: () -> Label
    
    private func performAction(_ direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment: value += 1
        case .decrement: value -= 1
        @unknown default:
            return
        }
    }
    
    var body: some View {
        HStack {
            Button{ performAction(.decrement) } label: {
                SwiftUI.Label("Decriment", systemImage: "minus")
                    .labelStyle(.iconOnly)
                
            }
            .disabled(value == range.lowerBound)
            
            VStack {
                label()
                    .font(.caption[.bold])
                    .opacity(0.5)
                
                SwiftUI.TextField("", value: $value, format: .number)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.exampleParameterValue)
            }
            .frame(height: .controlSize)
            .background{
                ContainerRelativeShape()
                    .opacity(0.1)
            }
        
            Button{  performAction(.increment) } label: {
                SwiftUI.Label("Incriment", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }
            .disabled(value == range.upperBound)
        }
    }
    
}

#Preview {
    InlineBinding(0){ b in
        ExampleStepper(value: b, range: 0...10){
            Text("Test")
        }
    }
    .buttonStyle(.example)
    .labelStyle(.iconOnly)
    .containerShape(.capsule)
    .previewSize()
}
