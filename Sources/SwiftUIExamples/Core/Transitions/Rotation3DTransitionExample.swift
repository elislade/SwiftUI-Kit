import SwiftUIKit


public struct Rotation3DTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static let name = "Rotation 3D Transition"
        static let angle = UnitAngle.degrees
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var rotX = Measurement(value: 0, unit: Self.angle)
        @State private var rotY = Measurement(value: 0, unit: Self.angle)
        @State private var rotZ = Measurement(value: 0, unit: Self.angle)
        @State private var anchor: UnitPoint = .center
        @State private var depth: Double = 0
        
        private var transition: AnyTransition {
            let deg = [rotX.value, rotY.value, rotZ.value].sorted(by: {
                $0.magnitude < $1.magnitude
            }).last!
            return .rotation3D(
                angle: .degrees(deg),
                axis: Axis3D(x: rotX.value / deg, y: rotY.value / deg, z: rotZ.value / deg),
                anchor: anchor,
                depth: depth
            )
        }
        
        var body: some View {
            HStack {
                ExampleSlider(
                    value: $rotX,
                    in: -360...360,
                    step: 1,
                    format: .parse(Self.angle)
                ){
                    Text("X")
                }
                .onChangePolyfill(of: rotX){ update(transition, nil) }
                
                ExampleSlider(
                    value: $rotY,
                    in: -360...360,
                    step: 1,
                    format: .parse(Self.angle)
                ){
                    Text("Y")
                }
                .onChangePolyfill(of: rotY){ update(transition, nil) }
                
                ExampleSlider(
                    value: $rotZ,
                    in: -360...360,
                    step: 1,
                    format: .parse(Self.angle)
                ){
                    Text("Z")
                }
                .onChangePolyfill(of: rotZ){ update(transition, nil) }
            }
            .onAppear { update(transition, nil) }
            
            ExampleSlider(value: .init($depth, in: -100...100, step: 1)){
                Text("Depth")
            }
            .onChangePolyfill(of: depth){ update(transition, nil) }
            
            ExampleCell.Anchor(anchor: $anchor)
                .onChangePolyfill(of: anchor){ update(transition, nil) }
        }
    }
    
}


#Preview {
    Rotation3DTransitionExample()
        .previewSize()
}
