import SwiftUIKit


public struct Rotation2DTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Rotation Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var rot: Double = .zero
        @State private var anchor = UnitPoint.center
        
        private var transition: AnyTransition {
            .rotation(angle: .degrees(rot), anchor: anchor)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("Degrees")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitAngle>(value: rot, unit: .degrees),
                        format: .measurement(width: .abbreviated)
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $rot, in : -360...360, step: 1)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: rot){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Anchor").font(.exampleParameterTitle)
                    
                    Group {
                        Text("X: ") + Text(anchor.x, format: .increment(0.01))
                        Text("Y: ") + Text(anchor.y, format: .increment(0.01))
                    }
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                ExampleControl.Anchor(value: $anchor)
                    .frame(width: 120, height: 120)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: anchor){ update(transition, nil) }
        }
    }
    
}


#Preview {
    Rotation2DTransitionExample()
        .previewSize()
}
