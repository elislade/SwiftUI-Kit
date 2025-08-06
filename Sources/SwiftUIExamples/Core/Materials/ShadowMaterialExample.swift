import SwiftUIKit


public struct ShadowMaterialExample: View {
    
    enum Direction: CaseIterable, Hashable {
        case inner
        case outer
    }
    
    @State private var radius: CGFloat = 10
    @State private var angle: Angle = .degrees(0)
    @State private var amount: CGFloat = 10
    @State private var direction: Direction = .inner
    
    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 30)
    }
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Shadow Material"){
            switch direction {
            case .inner:
                InnerShadowMaterial(
                    shape,
                    radius: radius,
                    angle: angle,
                    amount: amount
                )
                .padding()
            case .outer:
                OuterShadowMaterial(
                    shape,
                    radius: radius,
                    angle: angle,
                    amount: amount
                )
                .padding()
            }
        } parameters: {
            SegmentedPicker(
                selection: $direction.animation(.bouncy),
                items: Direction.allCases
            ){ dir in
                switch dir {
                case .inner: Text("Inner")
                case .outer: Text("Outer")
                }
            }
            .exampleParameterCell()
            
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button{
                    withAnimation(.bouncy){
                        radius = .random(in: 0...100)
                        amount = .random(in: 0...100)
                        angle = .degrees(.random(in: -180...180))
                    }
                } label: {
                    Text("Random")
                }
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Radius")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(radius, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $radius, in: 0...100)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Angle")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitAngle>(value: angle.degrees, unit: .degrees),
                        format: .measurement(
                            width: .narrow,
                            numberFormatStyle: .increment(0.1)
                        )
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $angle.degrees, in: -180...180)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Amount")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(amount, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $amount, in: 0...100)
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview {
    ShadowMaterialExample()
        .previewSize()
}
