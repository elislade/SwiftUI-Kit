import SwiftUIKit


public struct ScaleTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Scale Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        private var transition: AnyTransition {
            .scale(x: scale.x, y: scale.y, anchor: anchor)
        }
        
        @State private var isLinked = true
        @State private var scale: SIMD2<Double> = .zero
        @State private var anchor = UnitPoint.center
        
        var body: some View {
            VStack {
                HStack {
                    Text("Scale")
                        .font(.exampleParameterTitle)
                    
                    Button("Linked", systemImage: "lock\(isLinked ? "" : ".open" ).fill"){
                        isLinked.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(.hierarchical)
                    
                    Spacer()
                    Group {
                        Text(scale.x, format: .increment(0.01))
                        Text(scale.y, format: .increment(0.01))
                    }
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                }
                
                HStack(alignment: .center) {
                    Slider(value: $scale.x, in : -1...3, step: 0.1)
                    Slider(value: $scale.y, in : -1...3, step: 0.1)
                }
            }
            .exampleParameterCell()
            .onAppear { update(transition, nil) }
            .onChangePolyfill(of: scale){ old, new in
                if isLinked {
                    let changeMask = old .!= new
                    if let changeIdx = changeMask.indices.first(where: { changeMask[$0] }){
                        scale = [new[changeIdx], new[changeIdx]]
                    }
                }
                update(transition, nil)
            }
            
            HStack(alignment: .top) {
                Text("Anchor")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Group {
                    Text(anchor.x, format: .increment(0.01))
                    Text(anchor.y, format: .increment(0.01))
                }
                .font(.exampleParameterValue)
                
                ExampleControl.Anchor(value: $anchor)
                    .frame(width: 130, height: 130)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: anchor){ update(transition, nil) }
        }
    }
}


#Preview {
    ScaleTransitionExample()
        .previewSize()
}
