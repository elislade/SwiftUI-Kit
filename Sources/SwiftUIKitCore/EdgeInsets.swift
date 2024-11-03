import SwiftUI

public protocol EdgeConformance {
    
    associatedtype Value
    
    var top: Value { get set }
    var bottom: Value { get set }
    var leading: Value { get set }
    var trailing: Value { get set }
}

public extension EdgeConformance {
    
    mutating func invert(_ edge: Edge) {
        let savedEdge = get(edge)
        self[edge] = self[edge.inverse]
        self[edge.inverse] = savedEdge
    }
    
    mutating func set(edges: Edge.Set, value: Value) {
        if edges.contains(.leading) { leading = value }
        if edges.contains(.trailing) { trailing = value }
        if edges.contains(.top) { top = value }
        if edges.contains(.bottom) { bottom = value }
    }
    
    mutating func set(_ edge: Edge, value: Value) {
        switch edge {
        case .top: top = value
        case .leading: leading = value
        case .bottom: bottom = value
        case .trailing: trailing = value
        }
    }
    
    func get(_ edge: Edge) -> Value {
        switch edge {
        case .top: top
        case .leading: leading
        case .bottom: bottom
        case .trailing: trailing
        }
    }
    
    subscript(edge: Edge) -> Value {
        get { get(edge) }
        set { set(edge, value: newValue) }
    }
    
}

extension EdgeInsets : EdgeConformance {}

/// `EdgeInsets` where all of the insets are `Optional`.
public struct OptionalEdgeInsets: Hashable, Sendable, EdgeConformance {
    
    public static let none: OptionalEdgeInsets = .init()
    
    public var top: CGFloat?
    public var bottom: CGFloat?
    public var leading: CGFloat?
    public var trailing: CGFloat?
    
    public var allNil: Bool { self == .none }
    
    public init(top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }
    
}


extension OptionalEdgeInsets: Animatable {
    
    /// The type defining the data to animate.
    public typealias AnimatableData = AnimatablePair<AnimatablePair<CGFloat,CGFloat>, AnimatablePair<CGFloat, CGFloat>>

    /// The data to animate.
    public var animatableData: AnimatableData {
        get {
            let v = AnimatablePair(top ?? 0, bottom ?? 0)
            let h = AnimatablePair(leading ?? 0, trailing ?? 0)
            return AnimatablePair(v, h)
        }
        set {
            let v = newValue.first
            if top != nil { top = v.first }
            if bottom != nil { bottom = v.second }
            
            let h = newValue.second
            if leading != nil { leading = h.first }
            if trailing != nil { trailing = h.second }
        }
    }
    
}
