import SwiftUI


public extension View {
    
    nonisolated func windowInteractionHoverContext(
        hitTestOnStart: Bool = false,
        hapticsEnabled: Bool = true
    ) -> some View {
        modifier(WindowInteractionHoverContext(
            hapticsEnabled: hapticsEnabled,
            hitTestOnStart: hitTestOnStart
        ))
    }
    
    nonisolated func onWindowInteractionHover(perform action: @escaping (WindowInteractionHoverPhase) -> Void) -> some View {
        modifier(WindowInteractionHoverElementModifier(action: action))
    }
    
    nonisolated func windowInteractionHoverDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowInteractionHoverEnabled){ enabled in
            if disabled {
                enabled = false
            }
        }
    }
    
}


extension EnvironmentValues {
    
    @Entry var windowInteractionHoverEnabled = true
    
}


public enum WindowInteractionHoverPhase: Hashable, Sendable {
    
    /// Interaction entered element.
    case entered
    
    /// Interaction left element.
    case left
    
    /// Interaction ended on element.
    case ended
    
    public var hasEntered: Bool { self == .entered }
    public var hasLeft: Bool { self == .left }
    public var hasEnded: Bool { self == .ended }
    
}
