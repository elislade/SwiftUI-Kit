import SwiftUIKit


public struct SafeAreaCaptureExample: View {
    
    @GestureState(resetTransaction: .init(animation: .bouncy)) private var offset: CGSize = .zero
    @State private var captureEnabled = false
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Safe Area Capture") {
            VStack(spacing: 10) {
                Image(systemName: "chevron.compact.up")
                
                Text("Drag Me!")
                    .opacity(0.5)
                    .padding(.bottom, 5)
                
                Image(systemName: "chevron.compact.down")
            }
            .font(.title[.bold])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .releaseContainerSafeArea()
            .background{
                RoundedRectangle(cornerRadius: 60)
                    .fill(.tint)
                    .ignoresSafeArea(edges: captureEnabled ? [] : .all)
            }
            .offset(offset)
            .captureContainerSafeArea(edges: captureEnabled ? .all : [])
            .gesture(
                DragGesture()
                    .updating($offset){ gesture, state, transaction in
                        transaction.animation = .interactiveSpring
                        state = gesture.translation
                    }
            )
        } parameters: {
            Toggle(isOn: $captureEnabled){
                Text("Capture Enabled")
                    .font(.exampleParameterTitle)
            }
            .toggleStyle(.swiftUIKitSwitch)
            .exampleParameterCell()
        }
    }
    
    
}


#Preview {
    SafeAreaCaptureExample()
        .previewSize()
}
