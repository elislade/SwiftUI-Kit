import SwiftUI

extension View {

    public nonisolated func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        modifier(WindowDragModifier(action: action))
    }
    
    public nonisolated func windowDragDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowDragEnabled){ isEnabled in
            if disabled {
                isEnabled = false
            }
        }
    }
    
    @available(*, deprecated, renamed: "windowDragDisabled()")
    public nonisolated func disableWindowDrag(_ disabled: Bool = true) -> some View {
        windowDragDisabled(disabled)
    }
    
}


public struct WindowDragEvent: Sendable {
    
    public enum Phase: Sendable, BitwiseCopyable {
        case began
        case changed
        case ended
    }
    
    public let phase: Phase
    public let locations: [CGPoint]
    
}


extension EnvironmentValues {
    
    @Entry public var windowDragEnabled: Bool = true
    
}
