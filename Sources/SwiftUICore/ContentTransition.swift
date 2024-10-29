import SwiftUI

public extension View {
    
    
    /// Calls `contentTransition(.identity)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    @ViewBuilder func contentTransitionIdentity() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.contentTransition(.identity)
        } else {
            self
        }
    }
    
    
    /// Calls `contentTransition(.interpolate)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    @ViewBuilder func contentTransitionInterpolate() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.contentTransition(.interpolate)
        } else {
            self
        }
    }
    
    
    /// Calls `contentTransition(.opacity)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    @ViewBuilder func contentTransitionOpacity() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.contentTransition(.opacity)
        } else {
            self
        }
    }
    
    
    /// Calls `contentTransition(.numericText(countsDown: _))` on supporting systems and nothing on systems that don't.
    /// - Parameter countsDown: Bool indicating to use up or down for the transition. Defaults to false which equates to up transition.
    /// - Returns: A View.
    @ViewBuilder func contentTransitionNumericText(countsDown: Bool = false) -> some View {
        //NumericText does not work on iOS 16 even though it's marked as available.
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.contentTransition(.numericText(countsDown: countsDown))
        } else {
            self
        }
    }
    
    /// Calls `contentTransition(.symbolEffect)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    @ViewBuilder func contentTransitionSymbolEffect() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.contentTransition(.symbolEffect)
        } else {
            self
        }
    }
    
}
