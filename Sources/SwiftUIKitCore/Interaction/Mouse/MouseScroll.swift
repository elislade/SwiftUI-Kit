import SwiftUI


public extension View {
    
    #if canImport(GameController)
    
    nonisolated  func onMouseScroll(action: @escaping (MouseScrollEvent) -> Void) -> some View {
        modifier(MouseScrollModifier(action: action))
    }
    
    #else
    
    nonisolated func onMouseScroll(action: @escaping (MouseScrollEvent) -> Void) -> Self {
        self
    }
    
    #endif
    
}


public struct MouseScrollEvent: Hashable, Sendable, Codable, Identifiable {
    
    public enum Phase: Hashable, Sendable, Codable, BitwiseCopyable {
        case started
        case changed
        case ended
    }
    
    public let id: String
    public let phase: Phase
    public let delta: SIMD2<Double>
    
}
