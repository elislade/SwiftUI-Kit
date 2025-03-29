import SwiftUIKit


public struct ContainedBoundsExample: View {
    
    @State private var layoutDirection: LayoutDirection = .leftToRight
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Contained Bounds"){
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 16) {
                    ForEach(0...2){ _ in
                        HStack(spacing: 16) {
                            ForEach(0...9){ i in
                                Cell(i: i)
                            }
                        }
                        .frame(height: 110)
                    }
                }
                .padding()
            }
            .containedBoundsContext("Test")
            .scrollClipDisabledPolyfill()
            .border(.tint, width: 2)
            .padding(54)
            .clipped()
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
                    
                    EdgeLables(edges: state.edges)
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
        }
        
        
        struct EdgeLables: View {
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
