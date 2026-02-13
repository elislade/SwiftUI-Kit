import SwiftUIKit


struct ExampleSlider<Value, Label, FormatStyle> : View where
    Value: ValueBacked,
    Value.Backing == Double,
    Label: View,
    FormatStyle: ParseableFormatStyle,
    FormatStyle.FormatInput == Value,
    FormatStyle.FormatOutput == String
{
    
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    
    @Binding var value: Value
    let range: ClosedRange<Double>
    let step: Double?
    let format: FormatStyle
    let label: Label
    
    init(
        value: Binding<Clamped<Double>>,
        format: FormatStyle,
        @ViewBuilder label: () -> Label
    ) where Value == Double {
        self._value = value.backing
        self.range = value.wrappedValue.bounds
        self.step = value.wrappedValue.step
        self.format = format
        self.label = label()
    }
    
    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        format: FormatStyle,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self.range = bounds
        self.step = step
        self.format = format
        self.label = label()
    }
    
    var body: some View {
        let percentage = range.fraction(from: value.backing)
        HStack(spacing: 0) {
            label
                .font(isFocused ? .callout[.semibold] : .exampleParameterTitle)
                .labelStyle(.viewThatFits(preferring: \.title))
                .lineLimit(1)
                .lineSpacing(-2)
                .minimumScaleFactor(0.6)
            
            Spacer(minLength: 10)
            
            SwiftUI.TextField("", value: $value, format: format)
                .font(.exampleParameterValue)
//                        #if os(macOS)
//                        .textFieldStyle(.roundedBorder)
//                        #endif
                .textFieldStyle(.plain)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .padding(5)
                .padding(.horizontal, 3)
                .background{
                    RoundedRectangle(cornerRadius: 8)
                        .opacity(isFocused ? 0.1 : 0)
                }
                .multilineTextAlignment(.trailing)
                .fixedSize()
                .focused($isFocused)
        }
        .foregroundStyle(
            .white.shadow(.drop(
                color: .black.opacity(0.2), radius: 2, y: 1
            ))
        )
        .allowsHitTesting(false)
        .padding(.horizontal, 12)
        .opacity(isEnabled ? 1 : 0.5)
        .frame(height: .controlSize)
        .background{
            SliderView(
                x: .init($value.backing, in: range, step: step)
            )
        }
        .background{
            SunkenControlMaterial(ContainerRelativeShape())
                .scaleEffect(y: -1)

            Rectangle()
                .opacity(0.1)

            ContainerRelativeShape()
                .strokeBorder(.tint, lineWidth: isFocused ? 2 : 0)

            Rectangle()
                .scale(x: isFocused ? 1 : percentage, anchor: .leading)
                .fill(.tint)
                .opacity(isFocused ? 0.1 : isEnabled ? 0.9 : 0.4)
                .blendMode(.overlay)
            
        }
        .highPriorityGesture(
            TapGesture().onEnded{
                isFocused.toggle()
            }
        )
        .animation(.smooth.speed(1.6), value: isFocused)
        .compositingGroup()
        .clipShape(ContainerRelativeShape())
        .frame(minWidth: 120, maxWidth: .infinity)
        .containerShape(PercentageRoundedRectangle(.vertical, percentage: 0.7))
    }
    
}


extension ExampleSlider where FormatStyle == FloatingPointFormatStyle<Double> {
    
    init (
        value: Binding<Clamped<Double>>,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.init(value: value, format: .increment(0.1), label: label)
    }
    
}


#Preview {
    VStack {
        InlineBinding(Double.zero){ b in
            ExampleSlider(value: .init(b)){
                Label("Hello World", systemImage: "globe")
            }
        }
        
        InlineBinding(Measurement<UnitTemperature>(value: 34, unit: .celsius)){ b in
            ExampleSlider(
                value: b,
                in: -22...100,
                format: .parse(.celsius)
            ){
                Label("Temperature", systemImage: "thermometer.variable")
            }
        }
    }
    .padding()
    .previewSize()
}


extension CGFloat {
    
#if os(macOS)
    static let controlSize: Self = 38
#else
    static let controlSize: Self = 56
#endif
    
}


protocol ValueBacked {
    
    associatedtype Backing
    
    var backing: Backing { get set }
    
}


extension Double : ValueBacked {
    
    var backing: Double {
        get { self }
        set { self = newValue }
    }
    
}


extension Float : ValueBacked {
    
    var backing: Double {
        get { Double(self) }
        set { self = Float(newValue) }
    }
    
}


extension Measurement : ValueBacked {
    
    var backing: Double {
        get { value }
        set { value = newValue }
    }
    
}

extension Clamped: ValueBacked {
    
    var backing: Value {
        get { self.value }
        set { self.value = newValue }
    }
    
}
