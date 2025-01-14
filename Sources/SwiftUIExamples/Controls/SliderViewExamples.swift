import SwiftUIKit


public struct SliderViewExamples : View {
    
    @State private var direction = LayoutDirection.leftToRight
    @State private var useStepping = false
    @State private var hitTestHandle = false
    
    @SliderState(in: -4...(-1)) private var x = -2
    @SliderState(in: 1...8) private var y = 2
    
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
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        SliderView(x: _x, y: _y, hitTestHandle: hitTestHandle){ handle.frame(width: size * 3, height: size * 2)
                        }
                        .background{ bg }
                        
                        SliderView(_x, hitTestHandle: hitTestHandle){
                            handle.frame(width: size, height: size)
                        }
                        .background{ bg }
                        .frame(height: size)
                    }
                    
                    SliderView(vertical: _y, hitTestHandle: hitTestHandle){
                        handle.frame(width: size, height: size)
                    }
                    .background{ bg }
                    .frame(width: size)
                }
                
                SliderView(_x)
                    .background{
                        bg
                        
                        SunkenControlMaterial(isTinted: true)
                            .scaleEffect(x: _x.percentComplete, anchor: .leading)
                            .clipShape(Capsule())
                    }
                    .frame(height: size)
            }
            .animation(useStepping ? .bouncy : .fastSpringInteractive, value: x)
            .animation(useStepping ? .bouncy : .fastSpringInteractive, value: y)
            .padding()
            .environment(\.layoutDirection, direction)
        } parameters: {
            HStack {
                Text("Value")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Text("X ") + Text(x, format: .number.rounded(increment: 0.01))
                    .font(.exampleParameterValue)
                    .foregroundColor(.secondary)
                
                Text("Y ") + Text(y, format: .number.rounded(increment: 0.01))
                    .font(.exampleParameterValue)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $direction)
           
            Divider()
            
            Toggle(isOn: $hitTestHandle){
                Text("Hit Test Handle")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $useStepping){
                Text("Use Stepping")
                    .font(.exampleParameterTitle)
            }
            .padding()
            .syncValue(_useStepping.map{ $0 ? 1 : nil }, $x.step)
            .syncValue(_useStepping.map{ $0 ? 3 : nil }, $y.step)
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
    @State private var tint: Color = Color(
        hue: .random(in: 0...1), saturation: 0.9, brightness: 0.9
    )
    
    @State private var frequencies: [FrequencyGain] = [
        FrequencyGain(frequency: 48, gain: 0),
        FrequencyGain(frequency: 500, gain: 0),
        FrequencyGain(frequency: 1_000, gain: 0),
        FrequencyGain(frequency: 4_000, gain: 0),
        FrequencyGain(frequency: 6_000, gain: 0),
        FrequencyGain(frequency: 12_000, gain: 0),
        FrequencyGain(frequency: 18_000, gain: 0)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
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
                    
                    ForEach(frequencies){ f in
                        let i = frequencies.firstIndex(of: f)!
                        VStack(spacing: 0) {
                            Slider(value: $frequencies[i].gain)
                            
                            let formatted = formatFrequency(f.frequency)
                            
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
            
            Divider()
            
            ExampleTitle("Equalizer")
                .padding()
            
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
                .buttonStyle(.tintStyle)
            }
            .padding()
        }
        .background{
            ZStack {
                Rectangle()
                    .fill(.tint)
                    .zIndex(1)
                
                Rectangle()
                    .fill(.background)
                    .opacity(0.95)
                    .zIndex(2)
            }
            .ignoresSafeArea()
        }
        .tint(tint)
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
        
        @SliderState(in: -12...12) private var sliderValue: Double = 0
        
        var body: some View {
            SliderView(y: _sliderValue){
                RaisedControlMaterial(Circle())
                    .scaleEffect(y: -1)
            }
            .syncValue(_value, _sliderValue)
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
                            .scaleEffect(y: (_sliderValue.percentComplete - 0.5) * 1.9, anchor: .top)
                    }
                }
                .clipShape(Capsule())
                .padding(.horizontal, size / 4)
            }
            .scaleEffect(y: -1)
            .frame(maxWidth: .infinity)
            .animation(.interactiveSpring(duration: 0.3, extraBounce: 0.1), value: sliderValue)
        }
        
    }
    
}


#Preview("SliderView Equalizer") {
    SliderViewEqualizerExample()
        .previewSize()
}
