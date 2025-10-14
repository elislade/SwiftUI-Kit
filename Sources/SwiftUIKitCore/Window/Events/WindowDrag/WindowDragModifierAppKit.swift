import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowDragModifier {
    
    @Environment(\.windowDragEnabled) private var isEnabled
    @State private var windowRef: NSWindow?
    
    let action: (WindowDragEvent) -> Void
    
}

extension WindowDragModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.overlay {
            if isEnabled {
                Color.clear
                    .onAppear{ NSWindow.enterSwizzleSendEvents() }
                    .onDisappear{ NSWindow.exitSwizzleSendEvents() }
                    .windowReference{ windowRef = $0 }
                    .onReceive(WindowEvents.passthrough){ event in
                        guard let window = event.window, window == windowRef else { return }
                        let location = event.flippedYLocationInWindow
                        
                        if event.type.isMouseDown {
                            action(.init(phase: .began, locations: [location]))
                        } else if event.type.isMouseUp {
                            action(.init(phase: .ended, locations: [location]))
                        } else if event.type.isMouseDrag {
                            action(.init(phase: .changed, locations: [location]))
                        }
                    }
            }
        }
    }
    
}

#endif
