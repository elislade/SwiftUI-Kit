import SwiftUI

public struct SystemUIMask: OptionSet, Sendable {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let visualEffect = SystemUIMask(rawValue: 1 << 0)
    public static let alert = SystemUIMask(rawValue: 1 << 1)
    public static let tabbar = SystemUIMask(rawValue: 1 << 2)
    
    public static let sceneStatusbar = SystemUIMask(rawValue: 1 << 3)
    public static let bottomToolbar = SystemUIMask(rawValue: 1 << 4)
    public static let navigationTitlebar = SystemUIMask(rawValue: 3 << 5)

    public static let bars: SystemUIMask = [.sceneStatusbar, .bottomToolbar, .navigationTitlebar, .tabbar]
    
}


#if canImport(UIKit) && !os(visionOS)


public extension View {
    
    /// Overrides the `ColorScheme` for all masked views. This should be used when the style of a specific masked element should differ from the current `ColorScheme` of the window or its current view.
    /// - Parameters:
    ///   - scheme: The scheme you want to use for styling.
    ///   - uiMask: A mask of all the elements you want to include for styling.
    /// - Returns: A modified view capable of overriding `ColorScheme` of masked views.
    func overrideColorScheme(_ scheme: ColorScheme, uiMask: SystemUIMask) -> some View {
        modifier(SystemUIOverrideModifier( mask: uiMask, scheme: scheme))
    }
    
}

#else

public extension View {
    
    /// This is placeholder API stub that does nothing as this systems configuration does not support this modifier. This is left in to have consisten API callsites between different system configurations.
    /// - Parameters:
    ///   - scheme: The scheme you want to use for styling.
    ///   - uiMask: A mask of all the elements you want to include for styling.
    /// - Returns: Self as this modifier does not exist.
    func overrideColorScheme(_ scheme: ColorScheme, uiMask: SystemUIMask = []) -> Self {
        self
    }
    
}

#endif
