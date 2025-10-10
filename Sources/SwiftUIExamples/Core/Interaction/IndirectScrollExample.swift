import SwiftUIKit


public struct IndirectScrollExample: View {
    
    @State private var layout: LayoutDirection = .leftToRight
    @State private var hue: Double = .random(in: 0...1)
    @State private var scroll: SIMD2<Double> = .zero
    @State private var useMomentum: Bool = false
    @State private var mask: Axis.Set = [.horizontal]
    @State private var maskEvaluation: EventMaskEvaluationPhase = .onBegin
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Indirect Scroll") {
            ScrollView(showsIndicators: true) {
                VStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(height: 100)
                        .opacity(0.1)
                        .overlay { Text("Scroll Spacer Top") }
                    
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
                    .frame(height: 300)
                    .indirectScrollGesture(
                        IndirectScrollGesture(
                            useMomentum: useMomentum,
                            mask: mask,
                            maskEvaluation: maskEvaluation
                        )
                        .onChanged { value in
                            scroll += value.delta
                        }
                        .onEnded { _ in
                            withAnimation(.snappy){
                                scroll = .zero
                            }
                        }
                    )
                    
                    RoundedRectangle(cornerRadius: 30)
                        .frame(height: 100)
                        .opacity(0.1)
                        .overlay { Text("Scroll Spacer Bottom") }
                }
                .padding()
                .indirectScrollGroup()
            }
            .environment(\.layoutDirection, layout)
        } parameters: {
            Toggle(isOn: $useMomentum){
                Text("Use Momentum")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            .disabled(mask.isEmpty)
            
            ExampleCell.LayoutDirection(value: $layout)
            
            ExampleSection("Mask", isExpanded: true){
                Toggle(isOn: Binding($mask, contains: .horizontal)){
                    Text("Horizontal Axis")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: Binding($mask, contains: .vertical)){
                    Text("Vertical Axis")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                HStack {
                    Text("Evaluation Phase")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $maskEvaluation){
                        Text("On Change")
                            .tag(EventMaskEvaluationPhase.onChange)
                        
                        Text("On Begin")
                            .tag(EventMaskEvaluationPhase.onBegin)
                    }
                    .frame(maxWidth: 130, alignment: .trailing)
                }
                .exampleParameterCell()
                .disabled(mask.isEmpty)
            }
        }
    }
    
}


#Preview {
    IndirectScrollExample()
        .previewSize()
}
