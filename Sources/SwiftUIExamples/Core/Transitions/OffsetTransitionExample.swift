import SwiftUIKit


public struct OffsetTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }

    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Offset Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var offset: SIMD2<Double> = .zero
        
        private var transition: AnyTransition {
            .offset(offset)
        }
        
        var body: some View {
            HStack {
                ExampleSlider(value: .init($offset.x, in: -400...400)){
                    Text("Offset X")
                }
                
                ExampleSlider(value: .init($offset.y, in: -400...400)){
                    Text("Offset Y")
                }
            }
            .onChangePolyfill(of: offset){ update(transition, nil) }
            .onAppear { update(transition, nil) }
        }
    }
    
}


#Preview {
    OffsetTransitionExample()
        .previewSize()
}
