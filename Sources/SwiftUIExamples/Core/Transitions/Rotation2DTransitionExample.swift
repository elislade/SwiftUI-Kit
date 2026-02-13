import SwiftUIKit


public struct Rotation2DTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Rotation Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var rot = Measurement(value: 0, unit: UnitAngle.degrees)
        @State private var anchor = UnitPoint.center
        
        private var transition: AnyTransition {
            .rotation(angle: .degrees(rot.value), anchor: anchor)
        }
        
        var body: some View {
            ExampleSlider(
                value: $rot, in: -360...360, step: 1,
                format: .parse(.degrees)
            ){
                Text("Degrees")
            }
            .onChangePolyfill(of: rot){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            
            ExampleCell.Anchor(anchor: $anchor)
                .onChangePolyfill(of: anchor){ update(transition, nil) }
        }
    }
    
}


#Preview {
    Rotation2DTransitionExample()
        .previewSize()
}
