import SwiftUI


public extension Image {
    
#if canImport(UIKit)
    init(osImage: UIImage){
        self.init(uiImage: osImage)
    }
#elseif canImport(AppKit)
    init(osImage: NSImage){
        self.init(nsImage: osImage)
    }
#endif
    
}


public extension ColorScheme {
    
    /// Computes the inverse of the current `ColorScheme`.
    /// - Note: This may be unwise to rely on as ColorScheme's may not always have an inverse equivalent in the future. Under these circumstances it will just return self as the inverse.
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
    
    nonisolated func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
    
    nonisolated func offset(_ simd: SIMD2<Double>) -> some View {
        offset(x: simd.x, y: simd.y)
    }
    
    nonisolated func position(_ simd: SIMD2<Double>) -> some View {
        position(x: simd.x, y: simd.y)
    }
    
}


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

extension CharacterSet: @retroactive @unchecked Sendable { }

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

extension Character: @retroactive Identifiable {
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

extension Edge.Set: @retroactive Hashable { }

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


public extension Angle {
    
    init(rise: Float, run: Float) {
        self.init(radians: Double(atan2(rise, run)))
    }
    
    init(_ vector: SIMD2<Float>) {
        self.init(rise: vector.y, run: vector.x)
    }
    
}


extension View {
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func language(_ code: Locale.LanguageCode) -> some View {
        environment(\.locale, .init(languageComponents: .init(languageCode: code)))
            .environment(\.layoutDirection, .init(languageCode: code))
    }
    
}


extension LayoutDirection {
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(languageCode code: Locale.LanguageCode) {
        self = {
            let rtl: Set<Locale.LanguageCode> = [
                .arabic, .azerbaijani, .dhivehi, .hebrew, .kurdish, .persian, .urdu
            ]
            return rtl.contains(code) ? .rightToLeft : .leftToRight
        }()
    }
    
}


// MARK: Control Size


#if os(tvOS)

public enum ControlSize: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    
    /// A control version that is minimally sized.
    case mini
    
    /// A control version that is proportionally smaller size for space-constrained views.
    case small
    
    /// A control version that is the default size.
    case regular
    
    /// A control version that is prominently sized.
    case large
    
    /// A control version that is substantially sized. The largest control size.
    case extraLarge
}

public extension EnvironmentValues {

    @Entry var controlSize: ControlSize = .regular
    
}


public extension View {
    
    func controlSize(_ size: ControlSize) -> some View {
        environment(\.controlSize, size)
    }
    
}

#endif
