import SwiftUI


public extension View {
    
    func onMouseScroll(action: @escaping (MouseScrollEvent) -> Void) -> some View {
        modifier(MouseScrollModifier(action: action))
    }
    
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
