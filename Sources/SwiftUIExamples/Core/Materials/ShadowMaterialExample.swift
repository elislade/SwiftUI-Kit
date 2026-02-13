import SwiftUIKit


public struct ShadowMaterialExample: View {
    
    enum Direction: CaseIterable, Hashable {
        case inner
        case outer
    }
    
    @State private var radius: Double = 10
    @State private var angle = Measurement(value: 0, unit: UnitAngle.degrees)
    @State private var amount: Double = 10
    @State private var direction: Direction = .inner
    
    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 30)
    }
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Shadow Material"){
            Group {
                switch direction {
                case .inner:
                    InnerShadowMaterial(
                        shape,
                        radius: radius,
                        angle: .degrees(angle.value),
                        amount: amount
                    )
                case .outer:
                    OuterShadowMaterial(
                        shape,
                        radius: radius,
                        angle: .degrees(angle.value),
                        amount: amount
                    )
                }
            }
            .padding()
            .frame(maxWidth: 600, maxHeight: 600)
        } parameters: {
            HStack {
                ExampleInlinePicker(
                    data: Direction.allCases,
                    selection: $direction.animation(.bouncy)
                ){ dir in
                    switch dir {
                    case .inner: Text("Inner")
                    case .outer: Text("Outer")
                    }
                }
                
                Button{
                    withAnimation(.bouncy){
                        radius = .random(in: 0...100)
                        amount = .random(in: 0...100)
                        angle.value = .random(in: -180...180)
                    }
                } label: {
                    Label("Random", systemImage: "dice")
                }
            }
            
            HStack {
                ExampleSlider(value: .init($radius, in: 0...100)){
                    Label("Radius", systemImage:"beziercurve")
                }
                
                ExampleSlider(
                    value: $angle, in: -180...180,
                    format: .parse(.degrees)
                ){
                    Label("Angle", systemImage: "angle")
                }
            }

            ExampleSlider(value: .init($amount, in: 0...100)){
                Label("Magnitude", systemImage: "arrow.right.circle.dotted")
            }
        }
    }
    
}


#Preview {
    ShadowMaterialExample()
        .previewSize()
}
