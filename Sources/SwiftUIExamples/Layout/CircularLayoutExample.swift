import SwiftUIKit


public struct CircularLayoutExample : View {

    @State private var elements: [Double] = [
        .random(in: 0.1...1), .random(in: 0.1...1),  .random(in: 0.1...1)
    ]
    
    @State private var radius: Double = 100
    @State private var rangeLower: Angle = .zero
    @State private var rangeUpper: Angle = .degrees(360)
    @State private var offset: Angle = .zero
    @State private var compensateForRotation = false
    
    private var layout: some RelativeCollectionLayoutModifier {
        CircularCollectionLayout(
            radius: radius,
            offset: offset,
            range: rangeLower...rangeUpper,
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
            ZStackCollectionLayout(layout, data: elements.indices) { idx in
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 16), isTinted: true)
                    .opacity(Double(idx) / Double(elements.count))
                    .background(in: RoundedRectangle(cornerRadius: 16))
                    .frame(width: 60, height: 60)
                    .transition(.scale)
            }
            .drawingGroup()
            .animation(.fastSpring, value: compensateForRotation)
            .animation(.bouncy, value: elements)
        } parameters: {
            HStack {
                Text("Number of Items")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Text(elements.count, format: .number)
                    .font(.exampleParameterValue)
                
                Stepper(
                    onIncrement: { add() },
                    onDecrement: elements.isEmpty ? nil : { remove() }
                )
            }
            .exampleParameterCell()

            VStack {
                HStack {
                    Text("Radius")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(radius, format: .number)
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $radius, in: 50...150, step: 1)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Offset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(offset.degrees, format: .number)
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $offset.degrees, in: 0...360, step: 1)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Range")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(rangeUpper.degrees, format: .number)
                        .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(
                        value: $rangeUpper.degrees,
                        in: 0...360,
                        step: 1
                    )
                }
            }
            .exampleParameterCell()
            
            Toggle(isOn: $compensateForRotation){
                Text("Compensate Rotation")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
        }
    }
}


#Preview("Circular Layout") {
    CircularLayoutExample()
        .previewSize()
}
