import SwiftUI

public extension View {
    
    #if os(watchOS)
    
    func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        InlineEnvironmentReader(\.windowDragEnabled){ enabled in
            simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged{ action(.init(phase: .changed, locations: [$0.location])) }
                    .onEnded{ action(.init(phase: .ended, locations: [$0.location])) },
                including: enabled ? .all : .none
            )
        }
    }
    
    #else
    
    func onWindowDrag(perform action: @escaping (WindowDragEvent) -> Void) -> some View {
        modifier(WindowDragModifier(action: action))
    }
    
    #endif
    
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
