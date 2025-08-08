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

extension CharacterSet: @retroactive @unchecked Sendable { }

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

public extension SIMD2 where Scalar == Float {
    
    /// The orthogonal angle to the relative tangent of y and x.
    var angle: Angle {
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

public extension EnvironmentValues {

    @Entry var controlSize: ControlSize = .regular
    
}


public extension View {
    
    func controlSize(_ size: ControlSize) -> some View {
        environment(\.controlSize, size)
    }
    
}

#endif
