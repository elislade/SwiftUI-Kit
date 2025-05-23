import SwiftUI

public protocol EdgeConformance {
    
    associatedtype Value
    
    var top: Value { get set }
    var bottom: Value { get set }
    var leading: Value { get set }
    var trailing: Value { get set }
}

public extension EdgeConformance {
    
    mutating func swap(_ axis: Axis) {
        switch axis {
        case .horizontal: swap(.leading, with: .trailing)
        case .vertical: swap(.top, with: .bottom)
        }
    }
    
    mutating func swap(_ edgeA: Edge, with edgeB: Edge) {
        guard edgeA != edgeB else { return }
        let savedEdge = get(edgeA)
        self[edgeA] = self[edgeB]
        self[edgeB] = savedEdge
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
    
    public var top: Double?
    public var bottom: Double?
    public var leading: Double?
    public var trailing: Double?
    
    public var allNil: Bool { self == .none }
    
    public init(top: Double? = nil, bottom: Double? = nil, leading: Double? = nil, trailing: Double? = nil) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }
    
}


extension OptionalEdgeInsets: Animatable {
    
    public typealias VerticalData = AnimatablePair<Double, Double>
    public typealias HorizontalData = AnimatablePair<Double, Double>
    
    /// The type defining the data to animate.
    public typealias AnimatableData = AnimatablePair<VerticalData, HorizontalData>

    /// The data to animate.
    public var animatableData: AnimatableData {
        get {
            AnimatableData(
                VerticalData(top ?? 0, bottom ?? 0),
                HorizontalData(leading ?? 0, trailing ?? 0)
            )
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
