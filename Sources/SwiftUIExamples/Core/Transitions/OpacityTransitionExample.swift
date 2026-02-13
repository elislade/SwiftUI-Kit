import SwiftUIKit


public struct OpacityTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Opacity Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var opacity: Double = .zero
        
        private var transition: AnyTransition {
            .opacity(opacity)
        }
        
        var body: some View {
            ExampleSlider(value: .init($opacity)){
                Text("Opacity")
            }
            .onChangePolyfill(of: opacity){ update(transition, nil) }
            .onAppear { update(transition, nil) }
        }
    }
    
}


#Preview {
    OpacityTransitionExample()
        .previewSize()
}
