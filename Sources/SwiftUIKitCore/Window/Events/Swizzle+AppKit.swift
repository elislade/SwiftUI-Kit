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

extension NSEvent {
    
    @MainActor var flippedYLocationInWindow: CGPoint {
        guard let window else { return locationInWindow }
        return CGPoint(x: locationInWindow.x, y: window.frame.height - locationInWindow.y)
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
