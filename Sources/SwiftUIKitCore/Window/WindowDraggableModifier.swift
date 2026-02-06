import SwiftUI

#if os(macOS)

struct WindowDraggableModifier {
    
    @Environment(\.performWindowAction) private var performWindowAction
    @State private var action: () -> Void = { }
    
    let enabled: Bool
    
}

extension WindowDraggableModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.05){
                if enabled {
                    action()
                }
            }
            .windowReference{ window in
                action = {
                    window.trackEvents(
                        matching: [.leftMouseDragged, .leftMouseUp],
                        timeout: 0.2,
                        mode: .eventTracking
                    ){ evt, stop in
                        if let evt {
                            if evt.type == .leftMouseUp {
                                stop.pointee = true
                            } else {
                                evt.window?.performDrag(with: evt)
                            }
                        }
                    }
                }
            }
    }
    
}

#endif

extension View {
    
#if os(macOS)
    nonisolated public func windowDraggable(enabled: Bool = true) -> some View {
        modifier(WindowDraggableModifier(enabled: enabled))
    }
#else
    nonisolated public func windowDraggable(enabled: Bool = true) -> Self {
        self
    }
#endif
    
}
