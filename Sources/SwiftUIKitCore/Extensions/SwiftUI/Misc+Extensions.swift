import SwiftUI


extension Image {
    
#if canImport(UIKit)
    nonisolated public init(osImage: UIImage){
        self.init(uiImage: osImage)
    }
#elseif canImport(AppKit)
    public init(osImage: NSImage){
        self.init(nsImage: osImage)
    }
#endif
    
}


extension ColorScheme {
    
    /// Computes the inverse of the current `ColorScheme`.
    /// - Note: This may be unwise to rely on as ColorScheme's may not always have an inverse equivalent in the future. Under these circumstances it will just return self as the inverse.
    nonisolated public var inverse: ColorScheme {
        switch self {
        case .light: .dark
        case .dark: .light
        @unknown default: self
        }
    }
    
}


extension Axis {
    
    nonisolated public func inverse(_ enabled: Bool = true) -> Axis {
        enabled ? inverse : self
    }
    
    nonisolated public var inverse: Axis {
        switch self {
        case .horizontal: .vertical
        case .vertical: .horizontal
        }
    }

    nonisolated public var asSet: Axis.Set {
        switch self {
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }
    
    /// Initializes an `Axis` from an `Edge`.
    /// - Note: The `Edge` used is contained on the `Axis`.  Eg. The top `Edge` is having to do with y vertical geometry, so its `Axis` is vertical.
    /// - Parameter edge: An Edge.
    nonisolated public init(orthogonalTo edge: Edge) {
        switch edge {
        case .top, .bottom: self = .vertical
        case .leading, .trailing: self = .horizontal
        }
    }
    
}


extension Angle {
    
    nonisolated public init<Value: BinaryFloatingPoint>(rise: Value, run: Value) {
        self.init(radians: atan2(Double(rise), Double(run)))
    }
    
    nonisolated public init(_ vector: SIMD2<some BinaryFloatingPoint>) {
        self.init(rise: vector.y, run: vector.x)
    }
    
}

extension SIMD2 where Scalar == Float {
    
    /// The orthogonal angle to the relative tangent of y and x.
    nonisolated public var angle: Angle {
        Angle(radians: Double(atan2(y, x)))
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

extension EnvironmentValues {

    @Entry public var controlSize: ControlSize = .regular
    
}


extension View {
    
    nonisolated public func controlSize(_ size: ControlSize) -> some View {
        environment(\.controlSize, size)
    }
    
}

#endif
