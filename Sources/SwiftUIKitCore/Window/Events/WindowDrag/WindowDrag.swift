import SwiftUI

extension View {
    
    #if os(watchOS)
    
    public nonisolated func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        InlineEnvironmentValue(\.windowDragEnabled){ enabled in
            contentShape(Rectangle()).simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged{ action(.init(phase: .changed, locations: [$0.location])) }
                    .onEnded{ action(.init(phase: .ended, locations: [$0.location])) },
                including: enabled ? .all : .none
            )
        }
    }
    
    #else
    
    public nonisolated func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        modifier(WindowDragModifier(action: action))
    }
    
    #endif
    
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
