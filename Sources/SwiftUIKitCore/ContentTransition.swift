import SwiftUI

public extension View {
    
    
    /// Calls `contentTransition(.identity)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    nonisolated func contentTransitionIdentity() -> some View {
        contentTransition(.identity)
    }
    
    
    /// Calls `contentTransition(.interpolate)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    nonisolated func contentTransitionInterpolate() -> some View {
       contentTransition(.interpolate)
    }
    
    
    /// Calls `contentTransition(.opacity)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    nonisolated func contentTransitionOpacity() -> some View {
        contentTransition(.opacity)
    }
    
    
    /// Calls `contentTransition(.numericText(countsDown: _))` on supporting systems and nothing on systems that don't.
    /// - Parameter countsDown: Bool indicating to use up or down for the transition. Defaults to false which equates to up transition.
    /// - Returns: A View.
    @ViewBuilder nonisolated func contentTransitionNumericText(countsDown: Bool = false) -> some View {
        //NumericText does not work on iOS 16 even though it's marked as available.
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.contentTransition(.numericText(countsDown: countsDown))
        } else {
            self
        }
    }
    
    /// Calls `contentTransition(.symbolEffect)` on supporting systems and nothing on systems that don't.
    /// - Returns: A view.
    @ViewBuilder nonisolated func contentTransitionSymbolEffect() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.contentTransition(.symbolEffect)
        } else {
            self
        }
    }
    
}
