import SwiftUIKit


public struct BlurTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Blur Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var isOpaque: Bool = false
        @State private var radius: Double = 10
        
        private var transition: AnyTransition {
            .blur(radius: radius, opaque: isOpaque)
        }
        
        var body: some View {
            Toggle(isOn: $isOpaque){
                Text("Is Opaque")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: isOpaque){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            
            VStack {
                HStack {
                    Text("Radius")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                        
                    Text(radius, format: .increment(1))
                        .font(.exampleParameterValue)
                }
                .lineLimit(1)
                
        
                Slider(value: $radius, in: 0...200, step: 1)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: radius){ update(transition, nil) }
        }
    }
    
}


#Preview {
    BlurTransitionExample()
        .previewSize()
}
