import SwiftUI

public extension View {
    
    #if os(watchOS)
    
    func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
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
    
    nonisolated func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        modifier(WindowDragModifier(action: action))
    }
    
    #endif
    
    nonisolated func disableWindowDrag(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.windowDragEnabled){ isEnabled in
            if disabled {
                isEnabled = false
            }
        }
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


public extension EnvironmentValues {
    
    @Entry var windowDragEnabled: Bool = true
    
}
