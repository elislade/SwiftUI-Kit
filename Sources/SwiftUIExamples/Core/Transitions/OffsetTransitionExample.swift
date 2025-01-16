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
            VStack {
                HStack {
                    Text("Offset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                        
                    Group {
                        Text(offset.x, format: .increment(0.01))
                        Text(offset.y, format: .increment(0.01))
                    }
                    .font(.exampleParameterValue)
                }
                .lineLimit(1)
                
                HStack {
                    Slider(value: $offset.x, in: -400...400)
                    Slider(value: $offset.y, in: -400...400)
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: offset){ update(transition, nil) }
            .onAppear { update(transition, nil) }
        }
    }
    
}


#Preview {
    OffsetTransitionExample()
        .previewSize()
}
