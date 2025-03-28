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
            VStack {
                HStack {
                    Text("Max Width")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                        
                    Text(width, format: .increment(1))
                        .font(.exampleParameterValue)
                    
                    Switch(isOn: !$widthIsNill)
                        .controlSize(ControlSize.mini)
                }

                Slider(value: $width, in: 0...200, step: 1)
                    .disabled(widthIsNill)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: width){ update(transition, nil) }
            .onChangePolyfill(of: widthIsNill){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            
            VStack {
                HStack {
                    Text("Max Height")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                        
                    Text(height, format: .increment(1))
                        .font(.exampleParameterValue)
                    
                    Switch(isOn: !$heightIsNill)
                        .controlSize(ControlSize.mini)
                }
        
                Slider(value: $height, in: 0...200, step: 1)
                    .disabled(heightIsNill)
            }
            .exampleParameterCell()
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
