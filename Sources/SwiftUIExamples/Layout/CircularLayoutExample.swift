import SwiftUIKit


struct CircularLayoutExample : View {

    @State private var items: [Color] = [.random, .random, .random]
    @State private var width: Double = 260
    @State private var compensateForRotation = false
    
    var body: some View {
        ExampleView(title: "Circular Layout"){
            CircularLayoutView(
                data: items,
                compensateForRotation: compensateForRotation
            ){ color in
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 10), isTinted: true)
                    .tint(color)
                    .frame(width: 60, height: 60)
                    .drawingGroup()
                    .onTapGesture {
                        items.removeAll(where: { $0 == color })
                    }
            }
            .frame(width: width)
            .animation(.fastSpring, value: compensateForRotation)
        } parameters: {
            HStack {
                Text("Number of Items")
                    .font(.exampleParameterTitle)
                
                Text(items.count, format: .number)
                    .font(.exampleParameterValue)
                
                Spacer()
                
                Stepper(
                    onIncrement: { items.append(.random) },
                    onDecrement: {
                        guard items.isEmpty == false else { return }
                        items.removeLast()
                    }
                )
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Width")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(width, format: .number)
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $width, in: 100...400, step: 1)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $compensateForRotation){
                Text("Compensate Rotation")
                    .font(.exampleParameterTitle)
            }
            .padding()
        }
    }
}


#Preview("Circular Layout") {
    CircularLayoutExample()
}
