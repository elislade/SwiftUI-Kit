import SwiftUI

public extension View {
    
    func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        modifier(WindowDragModifier(action: action))
    }
    
    func disableWindowDrag(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowDragEnabled){ val in
            if disabled {
                val = false
            }
        }
    }
}


public struct WindowDragEvent {
    
    public enum Phase {
        case began
        case changed
        case ended
    }
    
    public let phase: Phase
    public let locations: [CGPoint]
    
}


struct WindowDragEnabledKey: EnvironmentKey {
    
    static var defaultValue: Bool { true }
    
}

extension EnvironmentValues {
    
    var windowDragEnabled: Bool {
        get { self[WindowDragEnabledKey.self] }
        set { self[WindowDragEnabledKey.self] = newValue }
    }
    
}
