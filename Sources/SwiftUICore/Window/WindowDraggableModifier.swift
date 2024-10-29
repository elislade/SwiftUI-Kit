import SwiftUI

#if canImport(AppKit)

struct WindowDraggableModifier: ViewModifier {
    
    @Environment(\.performWindowAction) private var performWindowAction
    
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged{
                performWindowAction(.translate($0.translation))
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
    
    func windowDraggable() -> some View {
        #if canImport(AppKit)
        modifier(WindowDraggableModifier())
        #else
        self
        #endif
    }
    
}
