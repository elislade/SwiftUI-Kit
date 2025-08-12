import SwiftUI


public extension View {
    
    #if os(watchOS) || os(visionOS) || os(tvOS)
    
    nonisolated func onWindowHover(perform action: @MainActor @escaping (WindowHoverEvent) -> Void) -> Self {
        self
    }
    
    #else
    
    nonisolated func onWindowHover(perform action: @MainActor @escaping (WindowHoverEvent) -> Void) -> some View {
        modifier(WindowHoverModifier(hover: action))
    }
    
    #endif
    
    nonisolated func disableWindowHover(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowHoverEnabled){ isEnabled in
            if disabled {
                isEnabled = false
            }
        }
    }
    
}


public struct WindowHoverEvent: Sendable {
    
    public let location: CGPoint
    
}

public extension EnvironmentValues {
    
    @Entry var windowHoverEnabled: Bool  = true
    
}
