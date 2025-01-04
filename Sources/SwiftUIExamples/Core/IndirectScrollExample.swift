import SwiftUIKit


public struct IndirectScrollExample: View {
    
    @State private var hue: Double = .random(in: 0...1)
    @State private var scroll: SIMD2<Double> = .zero
    @State private var useMomentum: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.gray.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hue: hue, saturation: 1, brightness: 0.8))
                    .offset(x: scroll.x, y: scroll.y)
                
                Button("Child Responder Test"){
                    hue = .random(in: 0...1)
                }
            }
            .indirectGesture(
                IndirectScrollGesture(useMomentum: useMomentum)
                    .onChanged { g in
                        scroll += g.delta
                    }
                    .onEnded { g in
                        withAnimation(.snappy){
                            scroll = .zero
                        }
                    }
            )
            .padding()
            
            ExampleTitle("Indirect Scroll")
            
            Toggle(isOn: $useMomentum){
                Text("Use Momentum")
                    .font(.exampleParameterTitle)
            }
            .padding()
            .toggleStyle(.swiftUIKitSwitch)
        }
    }
    
}


#Preview {
    IndirectScrollExample()
        .previewSize()
}
