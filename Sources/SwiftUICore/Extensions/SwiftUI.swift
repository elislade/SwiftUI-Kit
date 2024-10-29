import SwiftUI


public extension Image {
    
#if canImport(UIKit)
    @inlinable init(osImage: UIImage){
        self.init(uiImage: osImage)
    }
#elseif canImport(AppKit)
    @inlinable init(osImage: NSImage){
        self.init(nsImage: osImage)
    }
#endif
    
}


public extension ColorScheme {
    
    /// Computes the inverse of the current `ColorScheme`.
    /// - Note: This may be unwise to rely on as ColorScheme's may not always have an inverse equivilent in the future. Under these circumstances it will just return self as the inverse.
    var inverse: ColorScheme {
        switch self {
        case .light: .dark
        case .dark: .light
        @unknown default: self
        }
    }
    
}

public extension View {
    
    func maxReadableWidth(_ value: Double) -> some View {
        self
            .frame(maxWidth: value)
            .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder func geometryGroupPolyfill() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            geometryGroup()
        } else {
            self
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


public extension Edge {
    
    var inverse: Edge {
        switch self {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        }
    }
    
    init?(_ alignment: HorizontalAlignment) {
        if alignment == .leading {
            self = .leading
        } else if alignment == .trailing {
            self = .trailing
        } else {
            return nil
        }
    }
    
    init?(_ alignment: VerticalAlignment) {
        if alignment == .top {
            self = .top
        } else if alignment == .bottom {
            self = .bottom
        } else {
            return nil
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

extension Character: Identifiable {
    public var id: Self { self }
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


public extension Axis {
    
    var inverse: Axis {
        switch self {
        case .horizontal: .vertical
        case .vertical: .horizontal
        }
    }

    var asSet: Axis.Set {
        switch self {
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }
    
    /// Initializes an `Axis` from an `Edge`.
    /// - Note: The `Edge` used is contained on the `Axis`.  Eg. The top `Edge` is having to do with y vertical geometry, so its `Axis` is vertical.
    /// - Parameter edge: An Edge.
    init(orthogonalTo edge: Edge) {
        switch edge {
        case .top, .bottom: self = .vertical
        case .leading, .trailing: self = .horizontal
        }
    }
    
}


public protocol EmptyInitalizable {
    init()
}
