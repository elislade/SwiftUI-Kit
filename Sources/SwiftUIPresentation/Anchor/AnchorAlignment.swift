import SwiftUI


struct AnchorAlignment: Hashable, Sendable {
    
    static let auto = AnchorAlignment(.auto)
    
    let source: PointAnchor
    let presentation: PointAnchor
    
    init(_ mode: AnchorPresentationMetadata.AnchorMode){
        switch mode {
        case .auto:
            self.source = .auto
            self.presentation = .auto
        case .manual(let source, let presentation):
            self.source = .init(source)
            self.presentation = .init(presentation)
        }
    }
    
    init(source: PointAnchor, presentation: PointAnchor) {
        self.source = source
        self.presentation = presentation
    }
    
    init(autoAlignedOrthogonalToEdge edge: Edge){
        switch edge {
        case .top:
            self.init(
                source: .init(x: .auto, y: .fractional(UnitPoint.top.y)),
                presentation: .init(x: .auto, y: .fractional(UnitPoint.bottom.y))
            )
        case .leading:
            self.init(
                source: .init(x: .fractional(UnitPoint.leading.x), y: .auto),
                presentation: .init(x: .fractional(UnitPoint.trailing.x), y: .auto)
            )
        case .bottom:
            self.init(
                source: .init(x: .auto, y: .fractional(UnitPoint.bottom.y)),
                presentation: .init(x: .auto, y: .fractional(UnitPoint.top.y))
            )
        case .trailing:
            self.init(
                source: .init(x: .fractional(UnitPoint.trailing.x), y: .auto),
                presentation: .init(x: .fractional(UnitPoint.leading.x), y: .auto)
            )
        }
    }
    
}


public struct PointAnchor: Hashable, Sendable {
    
    public static let auto = PointAnchor(x: .auto, y: .auto)
    
    
    public enum Value: Hashable, Sendable {
        case auto
        case fractional(Double)
        
        public init(_ fraction: Double) {
            self = .fractional(fraction)
        }
        
        public var isAuto: Bool {
            if case .auto = self {
                return true
            } else {
                return false
            }
        }
        
        public var fraction: Double? {
            if case .fractional(let fraction) = self {
                return fraction
            } else {
                return nil
            }
        }
    }
    
    public var x: Value
    public var y: Value
    
    public var isAuto: Bool { x.isAuto && y.isAuto }
    
    public var unitPoint: UnitPoint? {
        guard let xfraction = x.fraction, let yfraction = y.fraction else {
            return nil
        }
        return UnitPoint(x: xfraction, y: yfraction)
    }
    
    public init(_ unitPoint: UnitPoint){
        self.x = .fractional(unitPoint.x)
        self.y = .fractional(unitPoint.y)
    }
    
    public init(x: Value, y: Value){
        self.x = x
        self.y = y
    }
    
    public subscript(axis: Axis) -> Value {
        get {
            switch axis {
            case .horizontal: return x
            case .vertical: return y
            }
        }
        set {
            switch axis {
            case .horizontal: x = newValue
            case .vertical: y = newValue
            }
        }
    }
    
}
