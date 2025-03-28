import SwiftUIKit


public struct CircularLayoutExample : View {

    @State private var items: [Color] = [.random, .random, .random]
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
    
    public var body: some View {
        ExampleView(title: "Circular Layout"){
            ZStackCollectionLayout(layout, data: items) { color in
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 10), isTinted: true)
                    .tint(color)
                    .frame(width: 60, height: 60)
                    .drawingGroup()
                    .transitions(.scale)
                    #if !os(tvOS)
                    .onTapGesture {
                        items.removeAll(where: { $0 == color })
                    }
                    #endif
            }
            .animation(.fastSpring, value: compensateForRotation)
            .animation(.bouncy, value: items)
        } parameters: {
            HStack {
                Text("Number of Items")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Text(items.count, format: .number)
                    .font(.exampleParameterValue)
                
                Stepper(
                    onIncrement: { items.append(.random) },
                    onDecrement: items.isEmpty ? nil : {
                        items.removeLast()
                    }
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
