import SwiftUIKit


public struct Rotation3DTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters: TransitionProviderView {
        
        static var name: String = "Rotation 3D Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var rot: SIMD3<Double> = .zero
        @State private var anchor: UnitPoint = .center
        @State private var depth: Double = 0
        
        private var axis: Axis3D {
            Axis3D(x: rot.x, y: rot.y, z: rot.z)
        }
        
        private var transition: AnyTransition {
            .rotation3D(
                angle: .degrees(360),
                axis: axis,
                anchor: anchor,
                depth: depth
            )
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("X Component")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitAngle>(value: rot.x * 360, unit: .degrees),
                        format: .measurement(width: .abbreviated)
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $rot.x, in : -1...1, step: 1/360)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: rot){ update(transition, nil) }
            .onAppear { update(transition, nil) }
            
            VStack {
                HStack {
                    Text("Y Component")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitAngle>(value: rot.y * 360, unit: .degrees),
                        format: .measurement(width: .abbreviated)
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $rot.y, in : -1...1, step: 1/360)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Z Component")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitAngle>(value: rot.z * 360, unit: .degrees),
                        format: .measurement(width: .abbreviated)
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $rot.z, in : -1...1, step: 1/360)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Depth")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(depth, format: .increment(1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $depth, in: -100...100, step: 1)
            }
            .exampleParameterCell()
            .onChangePolyfill(of: depth){ update(transition, nil) }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Anchor")
                        .font(.exampleParameterTitle)
                    
                    Group {
                        Text("X: ") + Text(anchor.x, format: .increment(0.1))
                        Text("Y: ") + Text(anchor.y, format: .increment(0.1))
                    }
                    .font(.exampleParameterValue)
                    .opacity(0.5)
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
    Rotation3DTransitionExample()
        .previewSize()
}
