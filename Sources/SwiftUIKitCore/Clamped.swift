import math_h


/// A wrapper around clamping logic and value percentage math.
///
public struct Clamped<Value: BinaryFloatingPoint> where Value.Stride : BinaryFloatingPoint {
    
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
    public init(_ value: Value = 0, in bounds: ClosedRange<Value> = 0...1, step: Value.Stride? = nil) {
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


extension Clamped: Equatable where Value : Equatable {}
extension Clamped: Sendable where Value: Sendable, Value.Stride: Sendable {}
