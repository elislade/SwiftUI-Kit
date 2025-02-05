import SwiftUI

#if canImport(AppKit)

struct WindowDraggableModifier: ViewModifier {
    
    @Environment(\.performWindowAction) private var performWindowAction
    
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.05){
                if enabled {
                    performWindowAction(.startMove)
                }
            }
    }
    
}

#endif

public extension View {
    
#if canImport(AppKit)
    func windowDraggable(enabled: Bool = true) -> some View {
        modifier(WindowDraggableModifier(enabled: enabled))
    }
#else
    func windowDraggable(enabled: Bool = true) -> Self {
        self
    }
#endif
    
}
