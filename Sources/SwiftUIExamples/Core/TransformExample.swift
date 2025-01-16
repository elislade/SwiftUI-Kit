import SwiftUIKit


public struct TransformExample: View {
    
    @State private var transform: Transform = .identity
    @State private var orderMask: [Transform.Component] = Transform.Component.allCases
    @State private var disableMask: Set<Transform.Component> = []
    @State private var syncedScale = false
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Transform"){
            ZStack {
                Color.clear
                    
                RoundedRectangle(cornerRadius: 20)
                    .fill(.tint)
                    .frame(width: 160, height: 160)
                    .transform(transform, orderMask: orderMask.filter({ !disableMask.contains($0) }))
            }
        } parameters: {
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Random"){
                    withAnimation(.smooth){
                        transform.shear = .random(in: -1...1)
                        transform.scale = .random(in: -1...1)
                        transform.rotation = .degrees(Double.random(in: -180...180))
                        transform.translation = .random(in: -200...200)
                    }
                }
                .font(.exampleParameterValue)
                
                Button("Reset"){
                    withAnimation(.smooth){
                        transform = .identity
                    }
                }
                .font(.exampleParameterValue)
                .disabled(transform == .identity)
            }
            .exampleParameterCell()

            VStack {
                HStack {
                    Text("Translate")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Group {
                        Text(transform.translation.x, format: .number.rounded(increment: 0.1)) + Text(",")
                        Text(transform.translation.y, format: .number.rounded(increment: 0.1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $transform.translation.x, in: -100...100)
                    Slider(value: $transform.translation.y, in: -100...100)
                }
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Shear")
                        .font(.exampleParameterTitle)
                    
                    Spacer()

                    Group {
                        Text(transform.shear.x, format: .number.rounded(increment: 0.1)) + Text(",")
                        Text(transform.shear.y, format: .number.rounded(increment: 0.1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $transform.shear.x, in: -0.5...0.5)
                    Slider(value: $transform.shear.y, in: -0.5...0.5)
                }
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Scale")
                        .font(.exampleParameterTitle)
                    
                    Button(action: { syncedScale.toggle() }){
                        Label{
                            Text("\(syncedScale ? "Unlock" : "Lock") Scale")
                        } icon: {
                            Image(systemName: "lock\(syncedScale ? "" : ".open").fill")
                        }
                    }
                    .labelStyle(.iconOnly)
                    
                    Spacer()
                    
                    Group {
                        Text(transform.scale.x, format: .number.rounded(increment: 0.1)) + Text(",")
                        Text(transform.scale.y, format: .number.rounded(increment: 0.1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $transform.scale.x, in: -1...1)
                    Slider(value: $transform.scale.y, in: -1...1)
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: transform.scale.x){
                if syncedScale {
                    transform.scale.y = transform.scale.x
                }
            }
            .onChangePolyfill(of: transform.scale.y){
                if syncedScale {
                    transform.scale.x = transform.scale.y
                }
            }
            
            VStack {
                HStack {
                    Text("Rotation")
                        .font(.exampleParameterTitle)
                    Spacer()
                    
                    Group {
                        Text(transform.rotation.degrees, format: .number.rounded(increment: 0.1)) + Text("º")
                    }
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $transform.rotation.degrees, in: -80...80)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Order Mask")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Button("Reset"){
                        orderMask = Transform.Component.allCases
                        disableMask = []
                    }
                    .font(.exampleParameterValue)
                    .disabled(orderMask == Transform.Component.allCases)
                }
                
                VStack(spacing: 0) {
                    ForEach(orderMask, id: \.hashValue){ mask in
                        let idx = orderMask.firstIndex(of: mask)!
                        Button(action: {
                            if disableMask.contains(mask) {
                                disableMask.remove(mask)
                            } else {
                                disableMask.insert(mask)
                            }
                        }){
                            HStack {
                                Image(systemName: "\(idx + 1).circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .imageScale(.large)
                                
                                Text("\(mask)".capitalized)
                                    .font(.exampleParameterValue[.semibold])
                                    .strikethrough(disableMask.contains(mask))
                                
                                Spacer()
                                
                                VStack(spacing: 6) {
                                    Button("Move Up", systemImage: "chevron.up"){
                                        if idx == 0 {
                                            orderMask.swapAt(idx, orderMask.count - 1)
                                        } else {
                                            orderMask.swapAt(idx, idx - 1)
                                        }
                                    }
                                    
                                    Button("Move Down", systemImage: "chevron.down"){
                                        if idx == orderMask.count - 1 {
                                            orderMask.swapAt(idx, 0)
                                        } else {
                                            orderMask.swapAt(idx, idx + 1)
                                        }
                                    }
                                }
                                .font(.exampleParameterValue[.heavy])
                                .labelStyle(.iconOnly)
                            }
                            .opacity(disableMask.contains(mask) ? 0.5 : 1)
                            .disabled(disableMask.contains(mask))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.secondary.opacity(0.1))
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                    }
                }
                .animation(.smooth, value: orderMask)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding()
        }
    }
    
}


#Preview("Transform"){
    TransformExample()
        .previewSize()
}
