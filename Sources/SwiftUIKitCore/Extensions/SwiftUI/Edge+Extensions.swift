import SwiftUI


public extension HorizontalEdge {
    
    var inverse: HorizontalEdge {
        switch self {
        case .leading: .trailing
        case .trailing: .leading
        }
    }
}

public extension VerticalEdge {
    
    var inverse: VerticalEdge {
        switch self {
        case .top: .bottom
        case .bottom: .top
        }
    }
    
}

public extension Edge {
    
    var inverse: Edge {
        switch self {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        }
    }
    
    static func random(in set: Edge.Set = .all) -> Edge {
        var generator = SystemRandomNumberGenerator()
        return random(in: set, using: &generator)
    }
    
    static func random<T: RandomNumberGenerator>(in set: Edge.Set = .all, using generator: inout T) -> Edge {
        let edges: [Edge] = Edge.allCases.filter{
            set.contains(.init($0))
        }
        
        return edges.randomElement(using: &generator) ?? .top
    }
    
}

public extension Edge.Set {
    
    init(_ axis: Axis.Set) {
        var set = Edge.Set()
        if axis.contains(.horizontal) { set.insert(.horizontal) }
        if axis.contains(.vertical) { set.insert(.vertical) }
        self = set
    }
    
    init(_ axis: Axis) {
        var set = Edge.Set()
        switch axis {
        case .horizontal: set.insert(.horizontal)
        case .vertical: set.insert(.vertical)
        }
        self = set
    }
    
}

extension Edge.Set: @retroactive Hashable { }
