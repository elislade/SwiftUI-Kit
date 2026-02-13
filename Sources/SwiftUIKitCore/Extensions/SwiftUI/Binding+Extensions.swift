import SwiftUI


public extension Binding {
    
    init<V: Sendable & Equatable>(_ base: Binding<Bool>, onValue: V) where Value == V? {
        self.init(
            get: { base.wrappedValue ? onValue : nil },
            set: { v, transaction in
                withTransaction(transaction){
                    base.wrappedValue = v == onValue
                }
            }
        )
    }
    
}


public extension Binding where Value == Bool {
    
    init<Set : SetAlgebra & Sendable>(_ binding: Binding<Set>, contains element: Set.Element) where Set.Element : Sendable {
        self.init(
            get: { binding.wrappedValue.contains(element) },
            set: { binding.wrappedValue.toggle(element, included: $0) }
        )
    }
    
    init<Set : SetAlgebra & Sendable>(_ binding: Binding<Set>, subset: Set) {
        self.init(
            get: { binding.wrappedValue.isSuperset(of: subset) },
            set: {
                if $0 {
                    binding.wrappedValue.formUnion(subset)
                } else {
                    binding.wrappedValue.subtract(subset)
                }
            }
        )
    }
    
    var inverse: Self {
        Binding(
            get: { !wrappedValue },
            set: { wrappedValue = !$0 }
        )
    }
    
    prefix static func ! (_ binding: Self) -> Self {
        binding.inverse
    }
    
}



public extension Binding where Value: Sendable {
    
    /// Get a sub binding from a keypath not just from the root binding value
    /// - NOTE: Useful if you have a binding to another wrapper type that has keyPath accessors.
    subscript<Subject>(path: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        .init(
            get: { wrappedValue[keyPath: path] },
            set: { wrappedValue[keyPath: path] = $0 }
        )
    }
    
}

extension Binding where Value : BinaryFloatingPoint, Value: Sendable {
    
    nonisolated public var double: Binding<Double> {
        .init(
            get: { Double(wrappedValue) },
            set: { wrappedValue = Value($0) }
        )
    }
    
}


// Don't think there is an issue with making keypaths sendable because they don't seem to be mutable.
// You can append paths but that returns a copy.
extension AnyKeyPath: @unchecked @retroactive Sendable {}
