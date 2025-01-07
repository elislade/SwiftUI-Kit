import SwiftUIKit


public struct OpacityTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Opacity Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var opcity: Double = .zero
        
        private var transition: AnyTransition {
            .opacity(opcity)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("Opacity")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                        
                    Text(opcity, format: .increment(0.01))
                        .font(.exampleParameterValue)
                }
                .lineLimit(1)
        
                Slider(value: $opcity, in: 0...1)
            }
            .padding()
            .onChangePolyfill(of: opcity){ update(transition, nil) }
            .onAppear { update(transition, nil) }
        }
    }
    
}


#Preview {
    OpacityTransitionExample()
        .previewSize()
}
