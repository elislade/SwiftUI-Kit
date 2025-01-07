import Foundation

public protocol EmptyInitalizable {
    init()
}

extension Never : EmptyInitalizable {
    
    public init() { fatalError() }
    
}

public protocol StaticIdentityConformance {
    
    static var identity: Self { get }
    
}


extension Never: StaticIdentityConformance {
    
    public static var identity: Never { fatalError() }

}


extension Double: EmptyInitalizable {}
extension Int : EmptyInitalizable {}
extension String : EmptyInitalizable {}


extension String: @retroactive Identifiable {
    public var id: String { self }
}


public func powRetainSign<V: BinaryFloatingPoint>(_ base: V, _ exponent: V) -> V {
    let res = V(pow(Double(abs(base)), Double(exponent)))
    return V(sign: base.sign, exponent: res.exponent, significand: res.significand)
}


public extension String {
    
    var splitCamelCaseFormat: String {
        reduce(into: ""){ res, partial in
            if res.isEmpty {
                res.append(partial.uppercased())
            } else if partial.isUppercase {
                res.append(" ")
                res.append(partial)
            } else {
                res.append(partial)
            }
        }
    }
    
}


public enum CompareType: String, CaseIterable, Hashable, Sendable, Codable {
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanOrEqual = ">="
    case lessThanOrEqual = "<="
    case equal = "=="
}

public func compare<T: Comparable>(_ lhs: T, _ type: CompareType, _ rhs: T) -> Bool {
    switch type {
    case .greaterThan: lhs > rhs
    case .lessThan: lhs < rhs
    case .equal: lhs == rhs
    case .greaterThanOrEqual: lhs >= rhs
    case .lessThanOrEqual: lhs <= rhs
    }
}


/// Resolves the keypath of an object through an escaping closure by way of subscript.
public struct ClosureKeyPath<T>: @unchecked Sendable {
    
    private let closure: () -> T
    
    public init(_ closure: @autoclosure @escaping () -> T) {
        self.closure = {
            DispatchQueue.global().sync {
                return closure()
            }
        }
    }
    
    public subscript<V: Sendable>(key: KeyPath<T, V>) -> V {
        closure()[keyPath: key]
    }
    
}


public extension ClosedRange where Bound : BinaryFloatingPoint {
    
    func value(from percent: Bound) -> Bound {
        let clampedPercent = percent.clamped(to: 0...1)
        return ((upperBound - lowerBound) * clampedPercent) + lowerBound
    }
    
    func fraction(from value: Bound) -> Bound {
        let clampedValue = value.clamped(to: self)
        return (clampedValue - lowerBound) / (upperBound - lowerBound)
    }
    
    func clamp(_ value: Bound) -> Bound {
        Swift.max(Swift.min(value, upperBound), lowerBound)
    }
    
}


public extension ClosedRange where Bound : BinaryFloatingPoint, Bound.Stride : BinaryFloatingPoint {
    
    func numberOfSteps(_ step: Bound.Stride) -> Int {
        Int(floor(Bound.Stride(upperBound - lowerBound) / step))
    }
    
}


public extension BinaryFloatingPoint {
    
    func fraction(in bounds: ClosedRange<Self>) -> Self {
        bounds.fraction(from: self)
    }
    
    func clamped(to bounds: ClosedRange<Self>) -> Self {
        bounds.clamp(self)
    }
    
    func round(to place: Self) -> Self {
        (self * place).rounded() / place
    }
    
}


public extension BinaryInteger {
    
    func clamped(to bounds: ClosedRange<Self>) -> Self {
        Swift.max(Swift.min(self, bounds.upperBound), bounds.lowerBound)
    }
    
}


public protocol ReplaceWhenFloatKeyIsTrueConformance {
    
    associatedtype Replacement : BinaryFloatingPoint
    
    nonisolated func replace(_ key: KeyPath<Replacement, Bool>, with replacement: Replacement) -> Self
    
}

public extension ReplaceWhenFloatKeyIsTrueConformance where Self == Replacement {
    
    func replace(_ key: KeyPath<Replacement, Bool>, with replacement: Replacement) -> Self {
        self[keyPath: key] ? replacement : self
    }
    
}


extension Double : ReplaceWhenFloatKeyIsTrueConformance {}
extension Float : ReplaceWhenFloatKeyIsTrueConformance {}
extension Float16 : ReplaceWhenFloatKeyIsTrueConformance {}


extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    
    public static func increment(_ increment: Double) -> FloatingPointFormatStyle<Double> {
        .number.rounded(increment: increment)
    }
    
}
