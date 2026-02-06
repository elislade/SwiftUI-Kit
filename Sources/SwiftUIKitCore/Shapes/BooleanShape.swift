import SwiftUI


/// Pre iOS 17 support for boolean operations on shapes.
struct BooleanShape<Base: Shape, Other: Shape> : Shape  {
    
    private let base: Base
    private let other: Other
    private let operation: BooleanShapeOperation
    private let eoFill: Bool
    
    init(_ base: Base, other: Other, operation: BooleanShapeOperation, eoFill: Bool = false) {
        self.base = base
        self.other = other
        self.operation = operation
        self.eoFill = eoFill
    }
    
    func path(in rect: CGRect) -> Path {
        let basePath = base.path(in: rect).cgPath
        let otherPath = other.path(in: rect).cgPath
        let fill: CGPathFillRule = eoFill ? .evenOdd : .winding
        
        return switch operation {
        case .subtract: Path(basePath.subtracting(otherPath, using: fill))
        case .union: Path(basePath.union(otherPath, using: fill))
        case .symmetricDifference: Path(basePath.symmetricDifference(otherPath, using: fill))
        case .intersection: Path(basePath.intersection(otherPath, using: fill))
        }
    }
    
}

extension BooleanShape: InsettableShape where Base : InsettableShape, Other: InsettableShape {
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        BooleanShape<Base.InsetShape, Other.InsetShape>(
            base.inset(by: amount),
            other: other.inset(by: amount),
            operation: operation,
            eoFill: eoFill
        )
    }
    
}


public enum BooleanShapeOperation: Sendable, BitwiseCopyable, CaseIterable {
    case subtract
    case union
    case symmetricDifference
    case intersection
}


extension Shape {
    
    @_disfavoredOverload
    nonisolated public func subtracting(_ other: some Shape, eoFill: Bool = false) -> some Shape {
        BooleanShape(self, other: other, operation: .subtract, eoFill: eoFill)
    }
    
    @_disfavoredOverload
    nonisolated public func union(_ other: some Shape, eoFill: Bool = false) -> some Shape {
        BooleanShape(self, other: other, operation: .union, eoFill: eoFill)
    }
    
    @_disfavoredOverload
    nonisolated public func symmetricDifference(_ other: some Shape, eoFill: Bool = false) -> some Shape {
        BooleanShape(self, other: other, operation: .symmetricDifference, eoFill: eoFill)
    }
    
    @_disfavoredOverload
    nonisolated public func intersection(_ other: some Shape, eoFill: Bool = false) -> some Shape {
        BooleanShape(self, other: other, operation: .intersection, eoFill: eoFill)
    }
    
    nonisolated public func boolean(
        _ operation: BooleanShapeOperation,
        with other: some Shape,
        eoFill: Bool = false
    ) -> some Shape {
        BooleanShape(self, other: other, operation: operation, eoFill: eoFill)
    }
    
}


extension InsettableShape {
    
    nonisolated public func boolean(
        _ operation: BooleanShapeOperation,
        with other: some InsettableShape,
        eoFill: Bool = false
    ) -> some InsettableShape {
        BooleanShape(self, other: other, operation: operation, eoFill: eoFill)
    }
    
}
