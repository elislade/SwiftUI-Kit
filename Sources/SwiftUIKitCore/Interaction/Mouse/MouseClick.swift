import SwiftUI


public extension View {
    
    func onMouseClick(action: @escaping (MouseClickEvent) -> Void) -> some View {
        modifier(MouseClickModifier(action: action))
    }
    
}

public struct MouseClickEvent: Hashable, Sendable {
    
    public enum Button: Hashable, Sendable {
        case left
        case right
        case other
    }

    public enum Phase: Hashable, Sendable {
        case down
        case up
    }
    
    public let button: Button
    public let phase: Phase
    public let location: CGPoint?
    
}
