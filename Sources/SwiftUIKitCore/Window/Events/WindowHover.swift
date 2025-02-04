import SwiftUI

public extension View {
    
    func onWindowHover(perform action: @MainActor @escaping (WindowHoverEvent) -> Void) -> some View {
        modifier(WindowHoverModifier(hover: action))
    }
    
    func disableWindowHover(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowHoverEnabled){ val in
            if disabled {
                val = false
            }
        }
    }
    
}


public struct WindowHoverEvent {
    
    public let location: CGPoint
    
}


struct WindowHoverEnabledKey: EnvironmentKey {
    
    static var defaultValue: Bool { true }
    
}

extension EnvironmentValues {
    
    var windowHoverEnabled: Bool {
        get { self[WindowHoverEnabledKey.self] }
        set { self[WindowHoverEnabledKey.self] = newValue }
    }
    
}
