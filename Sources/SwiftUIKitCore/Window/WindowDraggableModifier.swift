import SwiftUI

#if canImport(AppKit)

struct WindowDraggableModifier: ViewModifier {
    
    @Environment(\.performWindowAction) private var performWindowAction
    
    let enabled: Bool
    
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged{
                if enabled {
                    performWindowAction(.translate($0.translation))
                }
            }
    }
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .gesture(dragGesture)
    }
    
}

#endif

public extension View {
    
    func windowDraggable(enabled: Bool = true) -> some View {
        #if canImport(AppKit)
        modifier(WindowDraggableModifier(enabled: enabled))
        #else
        self
        #endif
    }
    
}
