import SwiftUI
import Combine


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

enum WindowEvents {
    
    @MainActor static var swizzledReferenceCount: UInt8 = 0
    @MainActor static var isSwizzled: Bool { swizzledReferenceCount > 0 }
    @MainActor static let passthrough = PassthroughSubject<NSEvent, Never>()
    
}

extension NSWindow {
    
    static func enterSwizzleSendEvents() {
        if WindowEvents.isSwizzled == false {
            toggleSwizzleSendEvent()
        }
        
        WindowEvents.swizzledReferenceCount += 1
    }
    
    static func exitSwizzleSendEvents() {
        WindowEvents.swizzledReferenceCount -= 1
        
        if WindowEvents.isSwizzled == false {
            toggleSwizzleSendEvent()
        }
    }
    
    static func toggleSwizzleSendEvent() {
        let ogMethod = class_getInstanceMethod(self, #selector(sendEvent))!
        let swizzleMethod = class_getInstanceMethod(self, #selector(swizzle__sendEvent))!
        
        method_exchangeImplementations(ogMethod, swizzleMethod)
    }
    
    @objc func swizzle__sendEvent(_ event: NSEvent) {
        swizzle__sendEvent(event)
        WindowEvents.passthrough.send(event)
    }
    
}

struct WindowEventsModifier: ViewModifier {
    
    @Environment(\._disableWindowEvents) private var isDisabled
    
    var started: @MainActor ([CGPoint]) -> Void
    var changed: @MainActor ([CGPoint]) -> Void
    var ended: @MainActor ([CGPoint]) -> Void
    
    private func flipYCoordinate(_ point: CGPoint, in window: NSWindow) -> CGPoint {
        CGPoint(x: point.x, y: window.frame.height - point.y)
    }
    
    func body(content: Content) -> some View {
        content.overlay {
            if !isDisabled {
                Color.clear
                    .onAppear { NSWindow.enterSwizzleSendEvents() }
                    .onDisappear{ NSWindow.exitSwizzleSendEvents() }
                    .onReceive(WindowEvents.passthrough){ event in
                        guard let window = event.window else { return }
                        let location = flipYCoordinate(event.locationInWindow, in: window)
                        
                        if event.type.isMouseDown {
                            started([location])
                        } else if event.type.isMouseUp {
                            ended([location])
                        } else if event.type.isMouseDrag {
                            changed([location])
                        }
                    }
            }
        }
    }
    
}

extension NSEvent.EventType {
    
    var isMouseDown: Bool {
        switch self {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return true
        default:
            return false
        }
    }
    
    var isMouseUp: Bool {
        switch self {
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return true
        default:
            return false
        }
    }
    
    var isMouseDrag: Bool {
        switch self {
        case .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
            return true
        default:
            return false
        }
    }
    
}

#endif
