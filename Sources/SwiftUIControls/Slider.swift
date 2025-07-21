import SwiftUI
import SwiftUIKitCore


/// A equivilent of SwiftUI Slider view.
public struct Slider<Value: BinaryFloatingPoint & Sendable>: View where Value.Stride : BinaryFloatingPoint & Sendable {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
    @Environment(\.isEnabled) private var isEnabled
    
    @Binding private var value: Clamped<Value>
    
    private var layoutVertical: Bool { layoutDirectionSuggestion.useVertical }
    
    /// Initializes instance
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - step: The distance between each valid value. Defaults to `nil`.
    public init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        step: Value.Stride? = nil
    ) {
        self._value = .init(value, in: bounds, step: step)
    }
    
    /// Initializes instance
    /// - Parameter state: Init from Clamped value.
    public init(_ value: Binding<Clamped<Value>>) {
        self._value = value
    }
    
    private var alignment: Alignment { layoutVertical ? .top : .leading }
    
    private var handleShape: some InsettableShape {
        RoundedRectangle(
            cornerRadius: (handleSize / 2) * (controlRoundness ?? 1)
        )
    }
    
    private var handleSize: Double {
        max(50 - (44 * interactionGranularity), 18)
    }
    
    public var body: some View {
        ZStack {
            if layoutVertical {
                SliderView(y: _value){
                    RaisedControlMaterialSecondary(handleShape)
                        .frame(width: handleSize, height: handleSize)
                        .scaleEffect(y: layoutDirectionSuggestion == .useBottomToTop ? -1 : 1)
                }
            } else {
                SliderView(x: _value){
                    RaisedControlMaterialSecondary(handleShape)
                        .frame(width: handleSize, height: handleSize)
                }
            }
        }
        .background {
            GeometryReader { proxy in
                let dimension = layoutVertical ? proxy.size.height : proxy.size.width
                let trackLength = ((dimension -  handleSize) * Double(value.percentComplete)) + (handleSize / 2)
                
                ZStack(alignment: alignment){
                    SunkenControlMaterial(Capsule())
                    SunkenControlMaterial(Capsule(), isTinted: true)
                        .frame(
                            width: layoutVertical ? nil : trackLength,
                            height: layoutVertical ? trackLength : nil,
                            alignment: alignment
                        )
                }
            }
            .frame(
                width: layoutVertical ? handleSize / 5 : nil,
                height: layoutVertical ? nil : handleSize / 5
            )
        }
        .scaleEffect(y: layoutDirectionSuggestion == .useBottomToTop ? -1 : 1)
        .frame(
            width: layoutVertical ? handleSize : nil,
            height: layoutVertical ? nil : handleSize
        )
        .compositingGroup()
        .opacity(isEnabled ? 1 : 0.5)
        .geometryGroupPolyfill()
        .accessibilityAdjustableAction{ direction in
            switch direction {
            case .increment: value.increment()
            case .decrement: value.decrement()
            @unknown default: return
            }
        }
    }
}


#if !os(tvOS)

extension SwiftUI.Slider where Label == EmptyView, ValueLabel == EmptyView {
    
    init<V: BinaryFloatingPoint>(_ value: Binding<Clamped<V>>) where V.Stride : BinaryFloatingPoint {
        self.init(
            value: value.value,
            in: value.wrappedValue.bounds,
            step: value.wrappedValue.step!
        )
    }
    
}

#endif

public extension Binding {
    
    init<V: BinaryFloatingPoint & Sendable>(
        _ value: Binding<V>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride? = nil
    ) where V.Stride : BinaryFloatingPoint & Sendable, Self.Value == Clamped<V> {
        self.init(
            get: { Clamped<V>(value.wrappedValue, in: bounds, step: step) },
            set: { value.wrappedValue = $0.value }
        )
    }
    
}
