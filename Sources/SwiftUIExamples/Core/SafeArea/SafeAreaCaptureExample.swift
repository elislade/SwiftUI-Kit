import SwiftUIKit


public struct SafeAreaCaptureExample: View {
    
    @GestureState private var offset: CGSize = .zero
    @State private var captureEnabled = false
    
    public init(){}
    
    public var body: some View {
        VStack(spacing: 12) {
            ExampleTitle("SafeArea Capture")
                .padding()
            
            Spacer()
            
            Image(systemName: "chevron.compact.up")
            
            Text("Drag Me!").opacity(0.5)
            
            Image(systemName: "chevron.compact.down")
            
            Spacer()
            
            Toggle(isOn: $captureEnabled){
                Text("Capture Enabled")
                    .font(.exampleParameterTitle)
            }
            .toggleStyle(.swiftUIKitSwitch)
            .exampleParameterCell()
        }
        .releaseContainerSafeArea()
        .background{
            RoundedRectangle(cornerRadius: 60)
                .fill(.bar)
                .ignoresSafeArea(edges: captureEnabled ? [] : .all)
        }
        .offset(offset)
        .captureContainerSafeArea(edges: captureEnabled ? .all : [])
        .gesture(
            DragGesture()
                .updating($offset){ a, b, c in
                    b = a.translation
                }
        )
    }
    
    
}


#Preview {
    SafeAreaCaptureExample()
        .previewSize()
}
