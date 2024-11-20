import SwiftUI
import SwiftUIKitCore


/// An improved version of the default `SwiftUI.Stepper` with support for `ControlSize` environment value as well as ``LayoutDirectionSuggestion``.
public struct Stepper: View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    
    @State private var activeDirection: AccessibilityAdjustmentDirection?
    @State private var actionTimerInterval: TimeInterval?
    @State private var actionTimerCount: Int = 0
    
    private var isVertical: Bool { layoutDirectionSuggestion.useVertical }
    
    private let onIncrement: (() -> Void)?
    private let onDecrement: (() -> Void)?
    
    /// Initializes instance
    /// - Parameters:
    ///   - onIncrement: A
    ///   - onDecrement: A
    public init(onIncrement: (() -> Void)? = nil, onDecrement: (() -> Void)? = nil){
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    /// Initializes instance
    /// - Parameters:
    ///   - value: A binding to a value that conforms to `Strideable`.
    ///   - step: The `Stride` of the `Strideable` value that you want to increment and decrement by. Defaults to 1.
    @inlinable public init<V: Strideable>(value: Binding<V>, step: V.Stride = 1) {
        self.init(
            onIncrement: {
                value.wrappedValue = value.wrappedValue.advanced(by: step)
            },
            onDecrement: {
                value.wrappedValue = value.wrappedValue.advanced(by: -step)
            }
        )
    }
    
    /// Initializes instance
    /// - Parameters:
    ///   - value: A binding to a value that conforms to `Strideable`.
    ///   - bounds: The valid bounds the stepper can step in.
    ///   - step: The `Stride` of the `Strideable` value that you want to increment and decrement by. Defaults to 1.
    @inlinable public init<V: Strideable>(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride = 1) {
        self.init(
            onIncrement: bounds.upperBound >= value.wrappedValue.advanced(by: step) ? {
                value.wrappedValue = value.wrappedValue.advanced(by: step)
            } : nil,
            onDecrement: bounds.lowerBound <= (value.wrappedValue.advanced(by: -step)) ? {
                value.wrappedValue = value.wrappedValue.advanced(by: -step)
            } : nil
        )
    }
    
    private func canPerformAction(_ direction: AccessibilityAdjustmentDirection) -> Bool {
        switch direction {
        case .increment: onIncrement != nil && isEnabled
        case .decrement: onDecrement != nil && isEnabled
        @unknown default: false
        }
    }
    
    private func performAction(_ direction: AccessibilityAdjustmentDirection){
        guard canPerformAction(direction) else { return }
        switch direction {
        case .increment: onIncrement?()
        case .decrement: onDecrement?()
        @unknown default: return
        }
    }
    
    private func stopActionRepitition() {
        actionTimerInterval = nil
        actionTimerCount = 0
    }
    
    private var linePadding: CGFloat {
        12 - (12 * interactionGranularity)
    }
    
    private var dividerPadding: CGFloat {
        12 - (12 * interactionGranularity)
    }
    
    private var controlFactor: CGFloat {
        switch controlSize {
        case .mini: 0.7
        case .small: 0.85
        case .regular: 1
        case .large: 1.2
        case .extraLarge: 1.4
        @unknown default: 1
        }
    }
    
    private var size: CGFloat {
        (44 - (24 * interactionGranularity)) * controlFactor
    }
    
    private func button(for direction: AccessibilityAdjustmentDirection, _ shape: some InsettableShape) -> some View {
        Button(
            shape: shape,
            direction: direction,
            isSelected: activeDirection == direction
        )
        .accessibilityAction { performAction(direction) }
        .disabled(!canPerformAction(direction))
    }
    
    private func content(for shape: some InsettableShape) -> some View {
        AxisStack(isVertical ? .vertical : .horizontal, spacing: 0){
            button(for: isVertical ? .increment : .decrement, shape)
         
            Divider()
                .padding(isVertical ? .horizontal : .vertical, dividerPadding)
                .opacity(activeDirection == nil ? 1 : 0)
            
            button(for: isVertical ? .decrement: .increment, shape)
        }
        .background {
            SunkenControlMaterial(shape)
        }
    }
    
    public var body: some View {
        content(for: RoundedRectangle(cornerRadius: (size / 2) * (controlRoundness ?? 1)))
            .aspectRatio(isVertical ? 0.5 : 2.8, contentMode: .fit)
            .frame(
                width: isVertical ? size : nil,
                height: isVertical ? nil : size
            )
            .fixedSize()
            .onChangePolyfill(of: actionTimerCount){
                guard let activeDirection else {
                    stopActionRepitition()
                    return
                }
                
                if canPerformAction(activeDirection){
                    performAction(activeDirection)
                } else {
                    stopActionRepitition()
                    self.activeDirection = nil
                }
            }
            .background{
                if let actionTimerInterval {
                    Color.clear.onReceive(Timer.every(actionTimerInterval).autoconnect()){ _ in
                        if actionTimerCount == 5 || actionTimerCount == 20 || actionTimerCount == 80 {
                            self.actionTimerInterval = actionTimerInterval / 3
                        }
                        
                        actionTimerCount += 1
                    }
                }
            }
            .overlay{
                GeometryReader { proxy in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { g in
                                    var directionCandidate: AccessibilityAdjustmentDirection
                                    
                                    if isVertical {
                                        directionCandidate = g.location.y < (proxy.size.height / 2) ? .increment : .decrement
                                    } else if layoutDirection == .leftToRight {
                                        directionCandidate = g.location.x > (proxy.size.width / 2) ? .increment : .decrement
                                    } else {
                                        directionCandidate = g.location.x < (proxy.size.width / 2) ? .increment : .decrement
                                    }
                                    
                                    if canPerformAction(directionCandidate){
                                        activeDirection = directionCandidate
                                        if actionTimerInterval == nil {
                                            actionTimerInterval = 0.5
                                        }
                                    }
                                }
                                .onEnded { g in
                                    stopActionRepitition()
                                    
                                    if let activeDirection {
                                        performAction(activeDirection)
                                    }
                                    
                                    activeDirection = nil
                                }
                        )
                }
            }
            .animation(.smooth.speed(2), value: activeDirection)
            .compositingGroup()
            .opacity(isEnabled ? 1 : 0.5)
            .accessibilityAdjustableAction(performAction)
    }
    
    
    struct Button<Shape: InsettableShape>: View {
        
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.interactionGranularity) private var interactionGranularity
        @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
        @Environment(\.controlSize) private var controlSize
        
        let shape: Shape
        let direction: AccessibilityAdjustmentDirection
        let isSelected: Bool
        
        private var imageName: String {
            switch direction {
            case .increment: "plus"
            case .decrement: "minus"
            @unknown default: ""
            }
        }
        
        private var transition: AnyTransition {
            .asymmetric(
                insertion: .merge(.scale(0.6), .opacity),
                removal: .opacity
            )
        }
        
        private var weight: Font.Weight {
            #if os(macOS)
            switch controlSize {
            case .mini: .heavy
            case .small: .bold
            case .regular, .large, .extraLarge: .semibold
            @unknown default: .semibold
            }
            #else
            .medium
            #endif
        }
        
        private var controlFactor: Double {
            switch controlSize {
            case .mini, .small: 0.75
            case .regular, .large, .extraLarge: 1
            @unknown default: 1
            }
        }
        
        private var padding: CGFloat {
            (12 - (8 * interactionGranularity)) * controlFactor
        }
        
        var body: some View {
            Color.clear
                .overlay{
                    ZStack {
                        Color.clear
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(isSelected ? .black : .primary)
                    }
                    .padding(padding)
                    .aspectRatio(1, contentMode: .fit)
                    .font(.body.weight(weight))
                }
                .background{
                    if isSelected {
                        RaisedControlMaterial(shape.inset(by: 2))
                            .transitions(transition)
                    }
                }
                .contentShape(shape)
                .opacity(isEnabled ? 1 : 0.5)
                .accessibilityAddTraits(.isButton)
        }
    }
}
