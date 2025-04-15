import SwiftUI
import SwiftUIKitCore


/// Abstracts bounds mapping and stepping to a property wrapper.
@dynamicMemberLookup @propertyWrapper public struct SliderState<Value: BinaryFloatingPoint> : DynamicProperty where Value.Stride : BinaryFloatingPoint  {

    public var wrappedValue: Value {
        get { backing.value }
        nonmutating set { backing.value = newValue }
    }
    
    @State private var backing: Projection
    
    
    /// Initializes instance
    ///
    /// - Parameters:
    ///   - value: The current value that conforms to `BinaryFloatingPoint`.
    ///   - bounds: A `ClosedRange` indicating the lower and upper bounds of the value. Defaults to `0...1`.
    ///   - step: The distance between each valid value. Defaults to `nil`.
    /// - Note: If a step does not fit evenly into the bounds, the value will be clipped to the most full step that fits in its bounds.
    public init(
        wrappedValue: Value = 0,
        in bounds: ClosedRange<Value> = 0...1,
        step: Value.Stride? = nil
    ) {
        self.backing = Projection(value: wrappedValue, in: bounds, step: step)
    }
    
    public subscript<V>(dynamicMember path: KeyPath<Projection, V>) -> V {
        backing[keyPath: path]
    }
    
    public subscript<V>(dynamicMember path: WritableKeyPath<Projection, V>) -> V {
        get { backing[keyPath: path] }
        nonmutating set { backing[keyPath: path] = newValue }
    }
    
    /// Increments value by step or by one tenth of value if step is nil.
    public func increment() { backing.increment() }
    
    /// Decrements value by step or by one tenth of value if step is nil.
    public func decrement() { backing.decrement() }
    
    public var projectedValue: Binding<Projection> {
        $backing
    }

}


extension SliderState {
    
    public struct Projection: Hashable {

        private var _value: Value
        
        public var bounds: ClosedRange<Value> {
            didSet {
                if !bounds.contains(_value) {
                    value = _value
                }
            }
        }
        
        public var step: Value.Stride? {
            didSet { value = _value }
        }
        
        public var boundsClampedToStep: ClosedRange<Value> {
            guard let step else { return bounds }
            let upper = bounds.lowerBound + (Value(bounds.numberOfSteps(step)) * Value(step))
            return bounds.lowerBound...upper
        }
        
        /// Initializes instance
        ///
        /// - Parameters:
        ///   - value: The current value that conforms to `BinaryFloatingPoint`.
        ///   - bounds: A `ClosedRange` indicating the lower and upper bounds of the value. Defaults to `0...1`.
        ///   - step: The distance between each valid value. Defaults to `nil`.
        /// - Note: If a step does not fit evenly into the bounds, the value will be clipped to the most full step that fits in its bounds.
        init(value: Value = 0, in bounds: ClosedRange<Value> = 0...1, step: Value.Stride? = nil) {
            self._value = value.clamped(to: bounds)
            self.bounds = bounds
            self.step = step
        }
        
        public var value: Value {
            get { _value }
            set {
                if let step {
                    let numberOfSteps = bounds.numberOfSteps(step)
                    let fraction = newValue.fraction(in: bounds)
                    _value = round(Value(numberOfSteps) * fraction) * Value(step) + bounds.lowerBound
                } else {
                    _value = newValue.clamped(to: bounds)
                }
            }
        }
        
        /// Gets or sets the value based on a range between 0 and 1 indicating how complete the value is.
        public var percentComplete: Value {
            get { value.fraction(in: boundsClampedToStep) }
            set { value = boundsClampedToStep.value(from: newValue) }
        }
        
        /// If this value has a step it will return a whole number indicating how many steps fits in its bounds. If this value has no step it will return nil.
        public var numberOfStepsInBounds: Int? {
            guard let step else { return nil }
            return bounds.numberOfSteps(step)
        }
        
        /// Increments value by step or by one tenth of value if step is nil.
        public mutating func increment() {
            var _step = (bounds.upperBound - bounds.lowerBound) / 10
            if let step { _step = Value(step) }
            value = min(value + _step, bounds.upperBound)
        }
        
        /// Decrements value by step or by one tenth of value if step is nil.
        public mutating func decrement() {
            var _step = (bounds.upperBound - bounds.lowerBound) / 10
            if let step { _step = Value(step) }
            value = max(value - _step, bounds.lowerBound)
        }
        
    }
    
}

extension SliderState : Sendable where Value : Sendable, Value.Stride : Sendable { }
extension SliderState.Projection : Sendable where Value : Sendable, Value.Stride : Sendable { }

extension SliderState: PropertyWrapper {}


public extension SwiftUI.Slider where Label == EmptyView, ValueLabel == EmptyView {
    
    nonisolated init<Value: BinaryFloatingPoint & Sendable>(
        _ state: SliderState<Value>, onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where Value.Stride : BinaryFloatingPoint & Sendable {
        if let step = state.step {
            self.init(
                value: .init(
                    get: { state.value },
                    set: { state.value = $0 }
                ),
                in: state.bounds,
                step: step,
                onEditingChanged: onEditingChanged
            )
        } else {
            self.init(
                value: .init(
                    get: { state.value },
                    set: { state.value = $0 }
                ),
                in: state.bounds,
                onEditingChanged: onEditingChanged
            )
        }
    }
    
}
