import SwiftUIKit


public struct CircularLayoutExample : View {

    @State private var elements: [Double] = [
        .random(in: 0.1...1), .random(in: 0.1...1),  .random(in: 0.1...1)
    ]
    
    @State private var numberOfItems: Int = 3
    @State private var radius: Double = 100
    @State private var rangeLower: Angle = .zero
    @State private var rangeUpper = Measurement(value: 360, unit: UnitAngle.degrees)
    @State private var offset: Angle = .zero
    @State private var compensateForRotation = false
    
    private var layout: some RelativeCollectionLayoutModifier {
        CircularCollectionLayout(
            radius: radius,
            offset: offset,
            range: rangeLower...Angle.degrees(rangeUpper.value),
            compensateForRotation: compensateForRotation
        )
    }
    
    public init() {}
    
    private func add() {
        elements.append(.random(in: 0.1...1))
    }
    
    private func remove() {
        elements.removeLast()
    }
    
    public var body: some View {
        ExampleView(title: "Circular Layout"){
            ZStackCollectionLayout(layout, data: Array(0...numberOfItems)) { idx in
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 16), isTinted: true)
                    .opacity(Double(idx) / Double(numberOfItems))
                    .background(in: RoundedRectangle(cornerRadius: 16))
                    .frame(width: 60, height: 60)
                    .transition(.scale)
            }
            .drawingGroup()
            .animation(.fastSpring, value: compensateForRotation)
            .animation(.bouncy, value: elements)
        } parameters: {
            ExampleStepper(value: $numberOfItems, range: 0...120){
                Text("Number of Items")
            }
            
            HStack {
                ExampleSlider(value: .init($radius, in: 50...150, step: 1)){
                    Text("Radius")
                }
                
                ExampleSlider(value: .init($offset.degrees, in: 0...360, step: 1)){
                    Text("Offset")
                }
            }
            
            HStack {
                ExampleSlider(
                    value: $rangeUpper,
                    in: 0...360,
                    step: 1,
                    format: .parse(.degrees)
                ){
                    Text("Range")
                }
            }
            
            Toggle(isOn: $compensateForRotation){
                Text("Compensate Rotation")
            }
        }
    }
}


#Preview("Circular Layout") {
    CircularLayoutExample()
        .previewSize()
}
