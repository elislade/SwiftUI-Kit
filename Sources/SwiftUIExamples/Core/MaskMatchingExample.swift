import SwiftUIKit


public struct MaskMatchingExample: View {
    
    @Namespace private var namespace
    @GestureState(reset: { _, t in t.animation = .bouncy }) private var offset: CGSize = .zero
    @State private var enabled: Bool = false
    
    public init(){}
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(.tint)
                .padding()
            
            Color.black
                .opacity(0.5)
                .maskMatching(using: namespace, enabled: enabled)
            
            Circle()
                .fill(.regularMaterial)
                .maskMatchingSource(using: namespace, enabled: enabled)
                .overlay {
                    Text("Drag Me")
                    Image(systemName: "dot.arrowtriangles.up.right.down.left.circle")
                        .resizable()
                        .padding()
                        .opacity(0.1)
                }
                .offset(offset)
                .padding()
                #if !os(tvOS)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ _ in enabled = true }
                        .onEnded{ _ in enabled = false }
                        .updating($offset){ state, b, _ in
                            b = state.translation
                        }
                )
                #endif
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            ExampleTitle("Mask Matching")
                .padding()
        }
    }
    
}


#Preview {
    MaskMatchingExample()
        .previewSize()
}
