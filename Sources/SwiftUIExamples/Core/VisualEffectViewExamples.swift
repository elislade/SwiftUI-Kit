import SwiftUIKit


public struct VisualEffectViewExamples : View {

    @State private var filters: BlurEffectView.Filters = .nonBlur
    @State private var blur: Double = 30
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Blur Effect View"){
            Canvas { ctx, canvasSize in
                let size = CGSizeMake(canvasSize.width / 21, canvasSize.height / 21)
                for i in 0...20 {
                    for j in 0...20 {
                        let origin = CGPoint(x: Double(j) * size.width, y: Double(i) * size.height)
                        let color = Color(
                            hue: Double(j) / 21,
                            saturation: (Double(i) / 10),
                            brightness: min(2 - (Double(i) / 10.0), 1)
                        )
                        ctx.fill(Path(CGRect(origin: origin, size: size)), with: .color(color))
                    }
                }
            }
            .overlay {
                BlurEffectView(filtersDisabled: filters, blurRadius: blur)
                    .id(filters.rawValue)
                    .id(blur)
            }
            .ignoresSafeArea()
        } parameters: {
            ExampleSection("Filters Disabled", isExpanded: true){
                Toggle(isOn: Binding($filters, contains: .sdrNormalize)){
                    Text("SDR Normalize")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: Binding($filters, contains: .luminanceCurveMap)){
                    Text("Luminance Curve Map")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: Binding($filters, contains: .colorBrightness)){
                    Text("Color Brightness")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: Binding($filters, contains: .colorSaturate)){
                    Text("Color Saturate")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                VStack {
                    Toggle(isOn: Binding($filters, contains: .gaussianBlur)){
                        LabeledContent {
                            Text(blur, format: .increment(0.1))
                                .font(.exampleParameterValue)
                        } label: {
                            Text("Gaussian Blur")
                                .font(.exampleParameterTitle)
                        }
                    }
                    
                    Slider(value: $blur, in: 0...80)
                        .disabled(filters.contains(.gaussianBlur))
                }
                .exampleParameterCell()
            }
        }
    }

}



#Preview("Blur Effect View") {
    VisualEffectViewExamples()
        .previewSize()
}
