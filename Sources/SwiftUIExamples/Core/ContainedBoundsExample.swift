import SwiftUIKit


public struct ContainedBoundsExample: View {
    
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @GestureState(reset: { _ , t in t.animation = .bouncy }) private var offset: CGSize = .zero
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Contained Bounds"){
            ZStack {
                Color.clear
                
                Cell(i: 0)
                    .frame(width: 120, height: 120)
                    .offset(offset)
                    #if !os(tvOS)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($offset) { value, state, _ in
                                state = value.translation
                            }
                    )
                    #endif
                    .environment(\.layoutDirection, .leftToRight)
            }
            .containedBoundsContext("Test")
            .scrollClipDisabledPolyfill()
            .border(.tint, width: 2)
            .frame(width: 170, height: 170)
            .environment(\.layoutDirection, layoutDirection)
        } parameters: {
            ExampleCell.LayoutDirection(value: $layoutDirection)
        }
    }
    
    
    struct Cell: View {
        
        @State private var state: ContainedBoundsState?
        
        let i: Int
        
        var body: some View {
            VStack {
                Text("Containment")
                    .font(.headline)
                    .fixedSize()

                if let state {
                    Text("\(state.containment)".capitalized)
                        .id(state.containment)
                    
                    Spacer(minLength: 1)
                    
                    EdgeLabels(edges: state.edges)
                        .font(.footnote)
                        .opacity(0.8)
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            .onContainedBoundsChange(in: "Test"){ state = $0 }
            .background{
                RoundedRectangle(cornerRadius: 22)
                    .opacity(0.05)
            }
            .geometryGroupIfAvailable()
        }
        
        
        struct EdgeLabels: View {
            let edges: Edge.Set
            
            var body: some View {
                if edges.contains(.leading) {
                    Text("Leading")
                }
                if edges.contains(.trailing) {
                    Text("Trailing")
                }
                if edges.contains(.top) {
                    Text("Top")
                }
                if edges.contains(.bottom) {
                    Text("Bottom")
                }
                if edges.isEmpty {
                    Text("None")
                }
            }
        }
        
    }
    
}


#Preview("Contained Bounds") {
    ContainedBoundsExample()
        .previewSize()
}
