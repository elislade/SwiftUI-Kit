import SwiftUIKit


public struct TransformExample: View {
    
    @State private var rotation = Measurement(value: 0, unit: UnitAngle.degrees)
    @State private var translation: SIMD2<Double> = .zero
    @State private var scale: SIMD2<Double> = [1,1]
    @State private var shear: SIMD2<Double> = .zero
    @State private var orderMask = Transform.Component.allCases
    @State private var disableMask: Set<Transform.Component> = []
    @State private var scaleSynced = false
    
    private var transform: Transform {
        .init(
            rotation: .degrees(rotation.value),
            translation: translation,
            scale: scale,
            shear: shear
        )
    }
    
    public init() {}
    
    private func row(for component: Transform.Component) -> some View {
        HStack {
            switch component {
            case .translation:
                ExampleSlider(value: .init($translation.x, in: -100...100)){
                    Label("Translate X", systemImage: "arcade.stick.and.arrow.left.and.arrow.right.outward")
                }
                
                ExampleSlider(value: .init($translation.y, in: -100...100)){
                    Label("Translate Y", systemImage: "arcade.stick.and.arrow.up.and.arrow.down")
                }
            case .scale:
                ExampleSlider(value: .init($scale.x, in: -1...1)){
                    Label("Scale X", systemImage: "rectangle.portrait.arrowtriangle.2.outward")
                }
                
                ExampleSlider(value: .init($scale.y, in: -1...1)){
                    Label("Scale Y", systemImage: "rectangle.arrowtriangle.2.outward")
                }
                
                Toggle(isOn: $scaleSynced){
                    Label("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        .symbolEffectRotateIfAvailable(value: scaleSynced)
                        .labelStyle(.iconOnly)
                }
                .toggleHintIndicatorVisibility(.hidden)
            case .rotation:
                ExampleSlider(
                    value: $rotation,
                    in: -80...80,
                    format: .parse(.degrees),
                ){
                    Label("Rotation", systemImage: "arrow.clockwise")
                }
            case .shear:
                ExampleSlider(value: .init($shear.x, in: -0.5...0.5)){
                    Label("Shear X", systemImage: "arrow.trianglehead.up.and.down.righttriangle.up.righttriangle.down.fill")
                }
                
                ExampleSlider(value: .init($shear.y, in: -0.5...0.5)){
                    Label("Shear Y", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right.fill")
                }
            }
        }
    }
    
    public var body: some View {
        ExampleView(title: "Transform"){
            ZStack {
                Color.clear
                    
                RoundedRectangle(cornerRadius: 20)
                    .fill(.tint)
                    .frame(maxWidth: 160, maxHeight: 160)
                    .padding()
                    .transform(
                        transform,
                        orderMask: orderMask.filter({ !disableMask.contains($0) })
                    )
            }
        } parameters: {
            HStack {
                Button{
                    withAnimation(.smooth){
                        shear = .random(in: -1...1)
                        if scaleSynced {
                            let value = Double.random(in: -1...1)
                            scale = [value, value]
                        } else {
                            scale = .random(in: -1...1)
                        }
                        rotation.value = .random(in: -180...180)
                        translation = .random(in: -200...200)
                    }
                } label: {
                    Label("Random", systemImage: "dice")
                        .frame(maxWidth: .infinity)
                }
                
                Button{
                    withAnimation(.smooth){
                        scale = [1,1]
                        translation = .zero
                        shear = .zero
                        rotation.value = 0
                    }
                } label: {
                    Label("Reset", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .disabled(transform == .identity)
            }
            
            ExampleSection(isExpanded: true){
                ForEach(orderMask, id: \.self){ mask in
                    row(for: mask)
                        .disabled(disableMask.contains(mask))
                        .geometryGroupIfAvailable()
                }
            } label: {
                Text("Parameters")
            }
            .animation(.smooth, value: orderMask)
            .background{
                if scaleSynced {
                    Color.clear
                        .onChangePolyfill(of: scale.x){ scale.y = scale.x }
                        .onChangePolyfill(of: scale.y){ scale.x = scale.y }
                }
            }
            
            ExampleSection{
                ForEach(orderMask, id: \.hashValue){ mask in
                    let idx = orderMask.firstIndex(of: mask)!
                    Button{
                        if disableMask.contains(mask) {
                            disableMask.remove(mask)
                        } else {
                            disableMask.insert(mask)
                        }
                    } label: {
                        HStack(spacing: 0) {
                            HStack {
                                Image(systemName: "\(idx + 1).circle.fill")
                                    .imageScale(.large)
                                
                                Text("\(mask)".capitalized)
                                    .strikethrough(disableMask.contains(mask))
                            }
                            .font(.exampleParameterTitle)
                            
                            Spacer(minLength: 12)
                            
                            HStack(spacing: 4) {
                                Button{
                                    if idx == 0 {
                                        orderMask.swapAt(idx, orderMask.count - 1)
                                    } else {
                                        orderMask.swapAt(idx, idx - 1)
                                    }
                                } label: {
                                    Label("Up", systemImage: "chevron.up")
                                        .labelStyle(.iconOnly)
                                }
                                
                                Button{
                                    if idx == orderMask.count - 1 {
                                        orderMask.swapAt(idx, 0)
                                    } else {
                                        orderMask.swapAt(idx, idx + 1)
                                    }
                                } label: {
                                    Label("Down", systemImage: "chevron.down")
                                        .labelStyle(.iconOnly)
                                }
                            }
                            #if os(watchOS)
                            .buttonStyle(.plain)
                            #endif
                        }
                        .lineLimit(1)
                        .opacity(disableMask.contains(mask) ? 0.5 : 1)
                        .disabled(disableMask.contains(mask))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .geometryGroupIfAvailable()
                }
                .animation(.smooth, value: orderMask)
            } label: {
                Text("Order Mask")
            }
        }
    }
    
}


#Preview("Transform"){
    TransformExample()
       .previewSize()
}
