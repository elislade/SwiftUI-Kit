import SwiftUI

// Window interaction hover is when an ongoing interaction has started and that interaction hovers overtop of an element. Similar to legacy UIKit touches entered, touches exited but predicated on an interaction already being started.

public extension View {
    
    nonisolated func windowInteractionHoverContext(hapticsEnabled: Bool = true) -> some View {
        modifier(WindowInteractionHoverContext(
            hapticsEnabled: hapticsEnabled
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
