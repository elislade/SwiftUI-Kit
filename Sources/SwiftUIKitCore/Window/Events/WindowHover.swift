import SwiftUI


public extension View {
    
    #if os(watchOS) || os(visionOS) || os(tvOS)
    
    func onWindowHover(perform action: @MainActor @escaping (WindowHoverEvent) -> Void) -> Self {
        self
    }
    
    #else
    
    func onWindowHover(perform action: @MainActor @escaping (WindowHoverEvent) -> Void) -> some View {
        modifier(WindowHoverModifier(hover: action))
    }
    
    #endif
    
    func disableWindowHover(_ disabled: Bool = true) -> some View {
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
