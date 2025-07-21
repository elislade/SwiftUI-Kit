import SwiftUI
import SwiftUIKitCore


/// Abstracts bounds mapping and stepping to a property wrapper.
@dynamicMemberLookup @propertyWrapper public struct SliderState<Value: BinaryFloatingPoint> : DynamicProperty where Value.Stride : BinaryFloatingPoint  {

    public var wrappedValue: Value {
        get { backing.value }
        nonmutating set { backing.value = newValue }
    }
    
    @State private var backing: Clamped<Value>
    
    
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
        self.backing = Clamped(wrappedValue, in: bounds, step: step)
    }
    
    public subscript<V>(dynamicMember path: KeyPath<Clamped<Value>, V>) -> V {
        backing[keyPath: path]
    }
    
    public subscript<V>(dynamicMember path: WritableKeyPath<Clamped<Value>, V>) -> V {
        get { backing[keyPath: path] }
        nonmutating set { backing[keyPath: path] = newValue }
    }
    
    /// Increments value by step or by one tenth of value if step is nil.
    public func increment() { backing.increment() }
    
    /// Decrements value by step or by one tenth of value if step is nil.
    public func decrement() { backing.decrement() }
    
    public var projectedValue: Binding<Clamped<Value>> {
        $backing
    }

}
