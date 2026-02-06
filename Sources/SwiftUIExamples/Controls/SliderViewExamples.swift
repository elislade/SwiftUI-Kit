import SwiftUIKit


public struct SliderViewExamples : View {
    
    @State private var direction = LayoutDirection.leftToRight
    @State private var hitTestHandle = true
    
    @State private var x = Clamped(-2, in: -4...(-1))
    @State private var y = Clamped(2, in: 1...8)
    
    private var size: Double = 40
    private var radius: Double { size / 2 }
    private var spacing: Double { radius }
    
    private var handle: some View {
        RaisedControlMaterial(RoundedRectangle(cornerRadius: radius).inset(by: 3))
    }
    
    private var bg: some View {
        SunkenControlMaterial(RoundedRectangle(cornerRadius: radius))
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Slider View"){
            Content(
                size: size,
                spacing: spacing,
                radius: radius,
                hitTestHandle: hitTestHandle,
                x: $x, y: $y
            )
            .padding()
            .environment(\.layoutDirection, direction)
            .indirectScrollGroup()
        } parameters: {
            ExampleCell.LayoutDirection(value: $direction)
            
            Toggle(isOn: $hitTestHandle){
                Text("Hit Test Handle")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleSection("X: \(x.value.formatted(.increment(0.01)))", isExpanded: true){
                EditStep(step: $x.step, bounds: x.bounds)
                EditBounds(bounds: $x.bounds)
            }
            
            ExampleSection("Y: \(y.value.formatted(.increment(0.01)))", isExpanded: true){
                EditStep(step: $y.step, bounds: x.bounds)
                EditBounds(bounds: $y.bounds)
            }
        }
    }
    
    struct EditBounds: View {
        
        @Binding var bounds: ClosedRange<Double>
        
        private var lower: Binding<Double> {
            .init(
                get: { bounds.lowerBound },
                set: { bounds = $0...bounds.upperBound }
            )
        }
        
        private var upper: Binding<Double> {
            .init(
                get: { bounds.upperBound },
                set: { bounds = bounds.lowerBound...$0 }
            )
        }
        
        var body: some View {
            VStack {
                HStack(spacing: 0){
                    Text("Range")
                        .font(.exampleParameterTitle)
                    
                    Spacer(minLength: 10)
                    Spacer(minLength: 10)
                    
                    Text(bounds.lowerBound, format: .increment(0.1))
                        .font(.exampleParameterValue) +
                    Text(" ... ") +
                    Text(bounds.upperBound, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(
                        value: lower,
                        in: (bounds.upperBound - 10)...(bounds.upperBound - 1),
                        step: 0.1
                    )
                    
                    Slider(
                        value: upper,
                        in: (bounds.lowerBound + 1)...(bounds.lowerBound + 10),
                        step: 0.1
                    )
                }
            }
            .exampleParameterCell()
        }
        
    }
    
    struct EditStep: View {
        
        @Binding var step: Double?
        let bounds: ClosedRange<Double>
        
        private var binding: Binding<Double> {
            .init(
                get: { step ?? 0 },
                set: { step = $0 }
            )
        }
        
        private var enabled: Binding<Bool> {
            .init(
                get: { step != nil },
                set: { step = $0 ? 0.1 : nil }
            )
        }
        
        var body: some View {
            VStack {
                HStack{
                    Toggle(isOn: enabled){
                        Text("Step")
                            .font(.exampleParameterTitle)
                    }
          
                    Text(binding.wrappedValue, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: binding)
                    .disabled(!enabled.wrappedValue)
            }
            .exampleParameterCell()
        }
        
    }
    
    struct Content: View {
        
        let size: Double
        let spacing: Double
        let radius: Double
        let hitTestHandle: Bool
        
        @Binding var x: Clamped<Double>
        @Binding var y: Clamped<Double>
        
        private var handle: some View {
            RaisedControlMaterial(RoundedRectangle(cornerRadius: radius).inset(by: 3))
        }
        
        private var bg: some View {
            SunkenControlMaterial(RoundedRectangle(cornerRadius: radius))
        }
        
        var body: some View {
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        SliderView(
                            x: $x, y: $y,
                            hitTestHandle: hitTestHandle
                        ){
                            handle
                                .frame(width: size * 3, height: size * 2)
                                .geometryGroupIfAvailable()
                        }
                        .background{ bg }
                        
                        SliderView(x: $x, hitTestHandle: hitTestHandle){
                            handle
                                .frame(width: size, height: size)
                                .geometryGroupIfAvailable()
                        }
                        .background{ bg }
                        .frame(height: size)
                    }
                    
                    SliderView(y: $y, hitTestHandle: hitTestHandle){
                        handle
                            .frame(width: size, height: size)
                            .geometryGroupIfAvailable()
                    }
                    .background{ bg }
                    .frame(width: size)
                }
                
                SliderView(x: $x)
                    .background{
                        bg
                        
                        SunkenControlMaterial(isTinted: true)
                            .scaleEffect(x: x.percentComplete, anchor: .leading)
                            .clipShape(Capsule())
                    }
                    .frame(height: size)
            }
        }
    }
}


#Preview("Slider View") {
    SliderViewExamples()
        .previewSize()
}

struct SliderViewEqualizerExample: View {
    
    struct FrequencyGain: Equatable, Identifiable {
        var id: Int { frequency }
        
        let frequency: Int // Hz
        var gain: Double // dB
    }
    
    let footerSize: CGFloat = 22
    
    @State private var master: Double = 0
    @State private var frequencies: [FrequencyGain] = [
        FrequencyGain(frequency: 00_048, gain: 0),
        FrequencyGain(frequency: 00_500, gain: 0),
        FrequencyGain(frequency: 01_000, gain: 0),
        FrequencyGain(frequency: 04_000, gain: 0),
        FrequencyGain(frequency: 06_000, gain: 0),
        FrequencyGain(frequency: 12_000, gain: 0),
        FrequencyGain(frequency: 18_000, gain: 0)
    ]
    
    var body: some View {
        ExampleView(title: "Equalizer"){
            ZStack {
                Color.clear

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Slider(value: $master, size: 18)
                        Text("Preamp")
                            .font(.system(.caption2, design: .serif)[.bold])
                            .lineLimit(1)
                            .frame(height: footerSize, alignment: .bottom)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    
                    VStack(alignment: .trailing) {
                        Text("+12")
                        Spacer()
                        Text("0") + Text("dB").font(.caption2)
                        Spacer()
                        Text("-12")
                    }
                    .font(.system(.body, design: .serif)[.bold])
                    .padding(.vertical, 4)
                    .padding(.bottom, footerSize)
                    .lineLimit(1)
                    
                    ForEach($frequencies){ f in
                        VStack(spacing: 0) {
                            Slider(value: f.gain)
                            
                            let formatted = formatFrequency(f.wrappedValue.frequency)
                            
                            Group {
                                Text(formatted.value) + Text(formatted.postfix)
                                    .fontWeight(.semibold)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(.caption2, design: .serif)[.bold])
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .frame(height: footerSize, alignment: .bottom)
                        }
                    }
                }
                .frame(height: 300)
                .background{
                    VStack(spacing: 0) {
                        GridLine(isMajor: true)
                        Spacer()
                        GridLine(isMajor: false)
                        Spacer()
                        GridLine(isMajor: true)
                        Spacer()
                        GridLine(isMajor: false)
                        Spacer()
                        GridLine(isMajor: true)
                    }
                    .padding(.vertical, 4)
                    .padding(.bottom, footerSize)
                }
                .padding()
            }
            .indirectScrollGroup()
            .indirectScrollInvertY()
        } parameters: {
            HStack{
                Text("Action")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Animate Random"){
                    for i in frequencies.indices {
                        frequencies[i].gain = .random(in: -12.0...12.0)
                    }
                }
                .font(.exampleParameterValue)
                .buttonStyle(.tinted)
            }
            .exampleParameterCell()
        }
    }
    
    struct GridLine: View {
        
        let isMajor: Bool
        
        var body: some View {
            Capsule()
                .fill(Color.primary.opacity(0.1))
                .frame(height: isMajor ? 2 : 1)
        }
    }
    
    struct Slider: View {
        
        @Binding var value: Double
        var size: CGFloat = 12
        
        @State private var clamped = Clamped(0, in: -12...12)
        
        var body: some View {
            SliderView(y: $clamped){
                RaisedControlMaterial(Circle())
                    .scaleEffect(y: -1)
            }
            .syncValue($value, $clamped.value)
            .frame(width: size)
            .background{
                ZStack {
                    SunkenControlMaterial(Capsule())

                    VStack(spacing: 0) {
                        Color.clear
                        Rectangle()
                            .fill(.tint)
                            .overlay{
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .black.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .blendMode(.overlay)
                            }
                            .scaleEffect(y: (clamped.percentComplete - 0.5) * 1.9, anchor: .top)
                    }
                }
                .clipShape(Capsule())
                .padding(.horizontal, size / 4)
            }
            .scaleEffect(y: -1)
            .frame(maxWidth: .infinity)
            .animation(.interactiveSpring(duration: 0.3, extraBounce: 0.1), value: clamped)
        }
        
    }
    
}


#Preview("SliderView Equalizer") {
    SliderViewEqualizerExample()
        .previewSize()
}
