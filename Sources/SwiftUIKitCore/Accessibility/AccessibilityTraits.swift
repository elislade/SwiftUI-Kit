import SwiftUI

public extension AccessibilityTraits {
    
    /// Computes a value that uses `.isToggle` on system versions that supports it and fallsback to `.isButton` on systems that don't.
    static var isTogglePolyfill: AccessibilityTraits {
        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return .isToggle
        } else {
            return .isButton
        }
    }
    
}
