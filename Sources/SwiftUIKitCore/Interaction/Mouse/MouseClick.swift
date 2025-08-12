import SwiftUI


public extension View {
    
    #if canImport(GameController)
    
    nonisolated func onMouseClick(action: @escaping (MouseClickEvent) -> Void) -> some View {
        modifier(MouseClickModifier(action: action))
    }
    
    #else
    
    nonisolated func onMouseClick(action: @escaping (MouseClickEvent) -> Void) -> Self {
        self
    }
    
    #endif
    
}

public struct MouseClickEvent: Hashable, Sendable, Codable, Identifiable {
    
    public enum Button: Hashable, Sendable, Codable, BitwiseCopyable {
        case left
        case right
        case middle
        case other
    }

    public enum Phase: Hashable, Sendable, Codable, BitwiseCopyable {
        case down
        case up
    }
    
    public let id: String
    public let button: Button
    public let phase: Phase
    public let location: SIMD2<Double>?
    
}
