import SwiftUI
import SwiftUIKitCore


/// A equivilent of SwiftUI Slider view.
public struct Slider<Value: BinaryFloatingPoint>: View where Value.Stride : BinaryFloatingPoint {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
    @Environment(\.isEnabled) private var isEnabled
    
    @Binding private var value: Value
    @SliderState private var state: Value
    
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
        self._value = value
        self._state = SliderState(wrappedValue: value.wrappedValue, in: bounds, step: step)
    }
    
    /// Initializes instance
    /// - Parameter state: Init from ``SliderState``.
    public init(_ state: SliderState<Value>) {
        self._value = .constant(0)
        self._state = state
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
        SliderView(x: layoutVertical ? nil : _state, y: layoutVertical ? _state : nil){
            RaisedControlMaterialSecondary(handleShape)
                .frame(width: handleSize, height: handleSize)
                .scaleEffect(y: layoutDirectionSuggestion == .useBottomToTop ? -1 : 1)
        }
        .background {
            GeometryReader { proxy in
                let dimension = layoutVertical ? proxy.size.height : proxy.size.width
                let trackLength = ((dimension -  handleSize) * Double(_state.percentComplete)) + (handleSize / 2)
                
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
        .syncValue(_state, _value)
        .geometryGroupPolyfill()
        .accessibilityAdjustableAction{ direction in
            switch direction {
            case .increment: _state.increment()
            case .decrement: _state.decrement()
            @unknown default: return
            }
        }
    }
}
