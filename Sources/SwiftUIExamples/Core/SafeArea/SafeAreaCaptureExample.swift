import SwiftUIKit


public struct SafeAreaCaptureExample: View {
    
    @GestureState(resetTransaction: .init(animation: .bouncy)) private var offset: CGSize = .zero
    @State private var captureEnabled = false
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Safe Area Capture") {
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
            .overlay {
                ZStack{
                    Capsule()
                        .frame(width: 100, height: 5)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    Capsule()
                        .frame(width: 100, height: 5)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    Capsule()
                        .frame(width: 5, height: 100)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Capsule()
                        .frame(width: 5, height: 100)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .foregroundStyle(
                    captureEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(.white.shadow(.drop(color: .black.opacity(0.1), radius: 1, y: 1)))
                )
                .padding(10)
            }
            .releaseContainerSafeArea()
            .background{
                ContainerRelativeShape()
                    .fill(.tint.opacity(0.15))
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
            }
        }
    }
    
    
}


#Preview {
    SafeAreaCaptureExample()
        .previewSize()
}
