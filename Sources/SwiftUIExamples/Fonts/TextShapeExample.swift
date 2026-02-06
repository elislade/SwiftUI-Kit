import SwiftUIKit


public struct TextShapeExample: View {
    
    @Environment(\.resolvedFont) private var resolvedFont
    
    @State private var customString: String = ""
    @State private var fontSize: Double = 62
    @State private var animating = false
    @State private var offset: SIMD2<Double> = .zero
    @GestureState private var panning: SIMD2<Double>?
    
    let string: String
    
    public init(
        string: String = "The quick brown fox jumps over the lazy dog."
    ){
        self.string = string
    }
    
    public var body: some View {
        let offset = CGPoint(offset + (panning ?? .zero))
        ExampleView(title: "Glyph Run"){
            TextShape(
                string: customString.isEmpty ? string : customString,
                font: .system(fontSize, weight: .heavy, design: .serif),
                inside: Rectangle()
                    .subtracting(
                        Circle()
                            .size(width: 120, height: 120)
                            .offset(offset)
                    )
            )
            .cache(isActive: panning == nil)
            .marchingAnts(active: animating)
            .fixedSize(horizontal: false, vertical: true)
            .overlay {
                Circle()
                    .size(width: 120, height: 120)
                    .fill(.tint.opacity(0.3))
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onEnded{ _ in
                                if let panning {
                                    self.offset += panning
                                }
                            }
                            .updating($panning){ value, state, transaction in
                                state = value.translation.simd
                            }
                    )
            }
            .geometryGroupIfAvailable()
            .onAppear{
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)){
                    animating = true
                }
            }
            .padding()
        } parameters : {
            VStack {
                HStack {
                    Text("Font Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(fontSize, format: .number)
                        .font(.exampleParameterValue)
                     + Text("pt.")
                }
                
                Slider(value: $fontSize, in: 10...200, step: 1)
            }
            .exampleParameterCell()
            
            TextField("String", text: $customString){}
                .exampleParameterCell()
        }
    }
    
}

#Preview {
    TextShapeExample()
        .previewSize()
}


extension Shape {
    
    nonisolated func marchingAnts(active: Bool) -> some View {
        fill(.tint).overlay {
            stroke(
                style: .init(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .bevel,
                    dash: [2, 4],
                    dashPhase: active ? 6 : 0
                )
            )
        }
    }
    
}
