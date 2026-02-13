import SwiftUIKit


public struct FrameTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Frame Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var alignment: Alignment = .center
        
        @State private var widthIsNill: Bool = false
        @State private var width: Double = 10
        
        @State private var heightIsNill: Bool = false
        @State private var height: Double = 10
        
        private var transition: AnyTransition {
            .frame(
                maxWidth: widthIsNill ? nil : width,
                maxHeight: heightIsNill ? nil : height,
                alignment: alignment
            )
        }
        
        var body: some View {
            HStack {
                ExampleSlider(
                    value: .init($width, in: 0...200, step: 1)
                ){
                    Text("Max Width")
                }
                .disabled(widthIsNill)
                
                Toggle(isOn: !$widthIsNill){
                    Text("Enabled")
                }
            }
            .onChangePolyfill(of: width){ update(transition, nil) }
            .onChangePolyfill(of: widthIsNill){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            .toggleHintIndicatorVisibility(.hidden)
            
            HStack {
                ExampleSlider(
                    value: .init($height, in: 0...200, step: 1)
                ){
                    Text("Max Height")
                }
                .disabled(heightIsNill)
                
                Toggle(isOn: !$heightIsNill){
                    Text("Enabled")
                }
            }
            .toggleHintIndicatorVisibility(.hidden)
            .onChangePolyfill(of: height){ update(transition, nil) }
            .onChangePolyfill(of: heightIsNill){ update(transition, nil) }
            
            ExampleCell.Alignment(value: $alignment)
                .onChangePolyfill(of: alignment){ update(transition, nil) }
        }
    }
    
}


#Preview {
    FrameTransitionExample()
        .previewSize()
}
