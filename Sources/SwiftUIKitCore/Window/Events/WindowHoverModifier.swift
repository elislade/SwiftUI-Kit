import SwiftUI


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowHoverModifier: ViewModifier {
    
    @Environment(\.windowHoverEnabled) private var isEnabled
    @State private var windowRef: NSWindow?
    
    let hover: @MainActor (WindowHoverEvent) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            if isEnabled {
                Color.clear
                    .onAppear{ NSWindow.enterSwizzleSendEvents() }
                    .onDisappear{ NSWindow.exitSwizzleSendEvents() }
                    .windowReference{ windowRef = $0 }
                    .onReceive(WindowEvents.passthrough){ event in
                        guard
                            let window = event.window,
                            window == windowRef,
                            event.type == .mouseMoved || event.type.isMouseUp
                        else { return }
                        
                        hover(.init(location: event.flippedYLocationInWindow))
                    }
            }
        }
    }
    
}

#else

struct WindowHoverModifier: ViewModifier {
    
    @Environment(\.windowHoverEnabled) private var isEnabled
    
    var hover: @MainActor (WindowHoverEvent) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            if isEnabled {
                Color.clear
                    .onAppear{ UIWindow.enterSwizzleSendEvents() }
                    .onDisappear{ UIWindow.exitSwizzleSendEvents() }
                    .onReceive(WindowEvents.passthrough){ event in
                        guard
                            event.type == .hover,
                            let touch = event.allTouches?.first(where: { $0.type != .direct })
                        else { return }
                        
                        hover(.init(location: touch.location(in: nil)))
                    }
            }
        }
    }
    
}

#endif
