import SwiftUIKit


public struct IndirectScrollExample: View {
    
    @State private var layout: LayoutDirection = .leftToRight
    @State private var useMomentum: Bool = false
    @State private var axes: Axis.Set = [.horizontal, .vertical]
    
    public init() {}
    
    private var responder: some View {
        Responder(
            useMomentum: useMomentum,
            axes: axes
        )
    }
    
    private var spacer: some View {
        RoundedRectangle(cornerRadius: 30)
            .opacity(0.1)
            .overlay { Text("Spacer") }
    }
    
    public var body: some View {
        ExampleView(title: "Indirect Scroll") {
            GeometryReader{ proxy in
                ScrollView(showsIndicators: true) {
                    VStack {
                        spacer
                        responder
                        spacer
                        responder
                    }
                    .padding()
                    .indirectScrollGroup()
                    .frame(height: proxy.size.height)
                }
            }
            .environment(\.layoutDirection, layout)
        } parameters: {
            Toggle(isOn: $useMomentum){
                Text("Use Momentum")
            }
            .disabled(axes.isEmpty)
            
            ExampleCell.LayoutDirection(value: $layout)
            
            ExampleSection("Axes", isExpanded: true){
                HStack {
                    Toggle(isOn: Binding($axes, contains: .horizontal)){
                        Label("X", systemImage: "arrow.left.and.right")
                    }
                    
                    Toggle(isOn: Binding($axes, contains: .vertical)){
                        Label("Y", systemImage: "arrow.up.and.down")
                    }
                }
            }
        }
    }
    
    
    struct Responder: View {
        
        @State private var scrollStart: SIMD2<Double>?
        @State private var scroll: SIMD2<Double> = .zero
        
        let useMomentum: Bool
        let axes: Axis.Set
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.gray.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.tint)
                    .offset(x: scroll.x, y: scroll.y)
                
                Button("Child Responder Test"){
                    withAnimation(.bouncy){
                        scroll = .zero
                    }
                }
            }
            .indirectScrollGesture(
                IndirectScrollGesture(axes: axes)
                .onChanged { value in
                    if let scrollStart {
                        withAnimation(.interactiveSpring){
                            scroll = scrollStart + value.translation
                        }
                    } else {
                        scrollStart = scroll
                    }
                }
                .onEnded { value in
                    guard let scrollStart else { return }
                    
                    if useMomentum {
                        withAnimation(.spring()){
                            scroll = scrollStart + value.predictedEndTranslation
                        }
                    }
                    
                    self.scrollStart = nil
                }
            )
        }
    }
    
}


#Preview {
    IndirectScrollExample()
        .previewSize()
}
