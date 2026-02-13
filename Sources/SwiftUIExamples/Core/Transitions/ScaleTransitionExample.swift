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
            HStack {
                ExampleSlider(value: .init($scale.x, in : -1...3, step: 0.1)){
                    Text("Scale X")
                }
                
                ExampleSlider(value: .init($scale.y, in : -1...3, step: 0.1)){
                    Text("Scale Y")
                }
                
                Toggle(isOn: $isLinked){
                    Label{ Text("Linked") } icon: {
                        Color.clear
                            .aspectRatio(0.5, contentMode: .fit)
                            .overlay{
                                Image(systemName: "lock\(isLinked ? "" : ".open" ).fill")
                            }
                    }
                    .labelStyle(.iconOnly)
                }
                .toggleHintIndicatorVisibility(.hidden)
                .symbolRenderingMode(.hierarchical)
            }
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
            
            ExampleCell.Anchor(anchor: $anchor)
                .onChangePolyfill(of: anchor){ update(transition, nil) }
        }
    }
}


#Preview {
    ScaleTransitionExample()
        .previewSize()
}
