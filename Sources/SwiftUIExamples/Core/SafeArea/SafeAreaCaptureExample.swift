import SwiftUIKit


public struct SafeAreaCaptureExample: View {
    
    @GestureState(resetTransaction: .init(animation: .bouncy)) private var offset: CGSize = .zero
    @State private var captureEnabled = false
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Safe Area Capture") {
            HStack(spacing: 0) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 5, height: 100)
                
                VStack(spacing: 0) {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 5)
                    
                    VStack(alignment: .leading) {
                        Text("Pan around.")
                            .font(.title[.bold])
                        
                        Text("Notice how the background interacts with the safearea.")
                            .font(.title3[.bold])
                            .opacity(0.5)
                    }
                    .frame(maxWidth: 320)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 5)
                }
                
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 5, height: 100)
            }
            .padding(5)
            .releaseContainerSafeArea()
            .background{
                ContainerRelativeShape()
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
