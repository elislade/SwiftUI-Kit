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


/// Resolves the keypath of an object through an escaping  MainActor closure by way of subscript.
@dynamicMemberLookup public struct MainActorClosureKeyPath<T>: Sendable {
    
    private let closure: @MainActor () -> T
    
    nonisolated public init(_ closure: @MainActor @autoclosure @escaping () -> T) {
        self.closure = closure
    }
    
    @MainActor public subscript<Subject>(key: KeyPath<T, Subject>) -> Subject {
        closure()[keyPath: key]
    }
    
    @MainActor public subscript<Subject>(dynamicMember key: KeyPath<T, Subject>) -> Subject {
        closure()[keyPath: key]
    }
    
}

/// Resolves the keypath of an object through an escaping  Sendable closure by way of subscript.
@dynamicMemberLookup public struct SendableClosureKeyPath<T>: Sendable {
    
    private let closure: @Sendable () -> T
    
    public init(_ closure: @Sendable @autoclosure @escaping () -> T) {
        self.closure = closure
    }
    
    public subscript<V: Sendable>(key: KeyPath<T, V>) -> V {
        closure()[keyPath: key]
    }
    
    public subscript<V: Sendable>(dynamicMember key: KeyPath<T, V>) -> V {
        closure()[keyPath: key]
    }
    
}


public extension ClosedRange where Bound : BinaryFloatingPoint {
    
    func value(from percent: Bound) -> Bound {
        let clampedPercent = percent.clamped(to: 0...1)
        return ((upperBound - lowerBound) * clampedPercent) + lowerBound
    }
    
    func fraction(from value: Bound, clamp: Bool = true) -> Bound {
        let value = clamp ? value.clamped(to: self) : value
        return (value - lowerBound) / (upperBound - lowerBound)
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
    
    func fraction(in bounds: ClosedRange<Self>, clamp: Bool = true) -> Self {
        bounds.fraction(from: self, clamp: clamp)
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


extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    
    public static func increment(_ increment: Double) -> FloatingPointFormatStyle<Double> {
        .number.rounded(increment: increment)
    }
    
}

extension FormatStyle where Self == FloatingPointFormatStyle<Float> {
    
    public static func increment(_ increment: Double) -> FloatingPointFormatStyle<Float> {
        .number.rounded(increment: increment)
    }
    
}

public func pow<T: BinaryInteger>(_ base: T, _ power: T) -> T {
    
    func expBySq(_ y: T, _ x: T, _ n: T) -> T {
        precondition(n >= 0)
        if n == 0 {
            return y
        } else if n == 1 {
            return y * x
        } else if n.isMultiple(of: 2) {
            return expBySq(y, x * x, n / 2)
        } else { // n is odd
            return expBySq(y * x, x * x, (n - 1) / 2)
        }
    }

    return expBySq(1, base, power)
}


public func formatFrequency(_ hertz: Int, compact: Bool = true) -> (value: String, postfix: String) {
    let attributedString = Measurement(
        value: Double(hertz),
        unit: UnitFrequency.hertz
    ).convertedToNearestWhole.formatted(.measurement(width: compact ? .narrow : .wide, usage: .asProvided).attributed)
    
    var value: [String] = []
    for run in attributedString.runs {
        let sub = attributedString.characters[run.range]
        if !sub.allSatisfy(\.isWhitespace) {
            value.append(String(sub))
        }
    }
    
    return (value[0], value[1])
}

public extension Measurement where UnitType == UnitFrequency {
    
    var convertedToNearestWhole: Self {
        let divisions: [UnitType] = [.nanohertz, .microhertz, .millihertz, .hertz, .kilohertz, .megahertz, .gigahertz, .terahertz]
        var index: Int = 0

        while true {
            let converted = converted(to: divisions[index])
            
            if converted.value.rounded() >= 1000 && divisions.indices.contains(index + 1) {
                index += 1
            } else {
                return Self(value: converted.value.rounded(), unit: converted.unit)
            }
        }
    }
    
}


public extension SetAlgebra {
    
    func intersects(with other: Self) -> Bool {
        !intersection(other).isEmpty
    }
    
}


public extension Set {
    
    mutating func toggle(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
    
}

public extension SetAlgebra {
    
    mutating func toggle(_ member: Element, included: Bool) {
        if included {
            insert(member)
        } else {
            remove(member)
        }
    }
    
}

public func nanoseconds(seconds: Double) -> UInt64 {
    UInt64(Double(NSEC_PER_SEC) * seconds)
}

public func nanoseconds(milliseconds: Double) -> UInt64 {
    nanoseconds(seconds: milliseconds / 1000)
}


public extension BinaryFloatingPoint {
    
    /// Incresenly stretches a value with resistance as it gets further outside the range's bounds.
    /// - Note: 0 resistance is the same as just using self, where as 1 is the same as clamping self to the range.
    /// - Parameters:
    ///   - range: A `ClosedRange` indicating the bounds from which to streach from, when outside.
    ///   - resistance: A relative amount of resistance ranging from 0(no-resistance) to 1(complete-resistance). Defaults to 0.3.
    /// - Returns: Self that is resisted past its bounds.
    func rubberBand(outside range: ClosedRange<Self>, withResistance resistance: CGFloat = 0.3) -> Self {
        if self > range.upperBound {
            let diff = self - range.upperBound
            return range.upperBound + Self(pow(Double(diff), 1 - resistance.clamped(to: 0...1)))
        } else if self < range.lowerBound {
            let diff = abs(self - range.lowerBound)
            return range.lowerBound - Self(pow(Double(diff), 1 - resistance.clamped(to: 0...1)))
        } else {
            return self
        }
    }
    
}


extension Duration {
    
    public var seconds: Double {
        Double(components.seconds) + (Double(components.attoseconds) / 1_000_000_000_000_000_000)
    }
    
}
