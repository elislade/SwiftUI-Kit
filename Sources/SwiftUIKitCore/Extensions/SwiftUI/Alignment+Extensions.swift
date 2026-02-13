import SwiftUI


extension Alignment {
    
    nonisolated public var inverse: Alignment {
        .init(
            horizontal: horizontal.inverse,
            vertical: vertical.inverse
        )
    }
    
    nonisolated public init(_ point: UnitPoint){
        self.init(
            horizontal: point.x == 0 ? .leading : point.x == 1 ? .trailing : .center,
            vertical: point.y == 0 ? .top : point.y == 1 ? .bottom : .center
        )
    }
    
    nonisolated public init(to edge: Edge) {
        switch edge {
        case .top: self = .top
        case .leading: self = .leading
        case .bottom: self = .bottom
        case .trailing: self = .trailing
        }
    }
    
    nonisolated public func invert(_ axis: Axis) -> Alignment {
        switch axis {
        case .horizontal: .init(horizontal: horizontal.inverse, vertical: vertical)
        case .vertical: .init(horizontal: horizontal, vertical: vertical.inverse)
        }
    }
    
}


extension HorizontalAlignment {
    
    nonisolated public var inverse: HorizontalAlignment {
        if self == .leading {
            return .trailing
        } else if self == .trailing {
            return .leading
        } else {
            return self
        }
    }
    
}

extension VerticalAlignment {
    
    nonisolated public var inverse: VerticalAlignment {
        if self == .top {
            return .bottom
        } else if self == .bottom {
            return .top
        } else {
            return self
        }
    }
    
}


extension UnitPoint {
    
    nonisolated public init(_ alignment: Alignment) {
        self.init(
            x: alignment.horizontal == .leading ? 0 : alignment.horizontal == .center ? 0.5 : 1,
            y: alignment.vertical == .top ? 0 : alignment.vertical == .center ? 0.5 : 1
        )
    }
    
    nonisolated public init(_ edge: Edge){
        var x: Double = 0.5, y: Double = 0.5
        switch edge {
        case .top: y = 0
        case .leading: x = 0
        case .bottom: y = 1
        case .trailing: x = 1
        }
        self.init(x: x, y: y)
    }
    
    nonisolated public func invert(_ axis: Axis.Set) -> UnitPoint {
        guard !axis.isEmpty else { return self }
        let inverse = inverse
        return .init(
            x: axis.contains(.horizontal) ? inverse.x : x,
            y: axis.contains(.vertical) ? inverse.y : y
        )
    }
    
    nonisolated public func invert(_ axis: Axis) -> UnitPoint {
        invert(axis.asSet)
    }
        
    nonisolated public subscript(axis: Axis) -> Double {
        get {
            switch axis {
            case .horizontal: x
            case .vertical: y
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


extension Edge {
    
    nonisolated public init?(_ alignment: HorizontalAlignment) {
        if alignment == .leading {
            self = .leading
        } else if alignment == .trailing {
            self = .trailing
        } else {
            return nil
        }
    }
    
    nonisolated public init?(_ alignment: VerticalAlignment) {
        if alignment == .top {
            self = .top
        } else if alignment == .bottom {
            self = .bottom
        } else {
            return nil
        }
    }
    
}
