import SwiftUI
import Combine

#if canImport(UIKit)

enum WindowEvents {
    
    @MainActor static var swizzledReferenceCount: UInt8 = 0
    @MainActor static var isSwizzled: Bool { swizzledReferenceCount > 0 }
    @MainActor static let passthrough = PassthroughSubject<UIEvent, Never>()
    
}

extension UIWindow {
    
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
    
    @objc func swizzle__sendEvent(_ event: UIEvent) {
        swizzle__sendEvent(event)
        WindowEvents.passthrough.send(event)
    }
    
}

#endif


struct WindowEventsModifier: ViewModifier {
    
    @Environment(\._disableWindowEvents) private var isDisabled
    
    var started: (() -> Void)?
    var ended: (() -> Void)?
    var changed: (([CGPoint]) -> Void)?
    
    private var hasListener: Bool {
        changed != nil || started != nil || ended != nil
    }
    
    func body(content: Content) -> some View {
        content
        #if canImport(UIKit)
            .onAppear {
                if hasListener, !isDisabled {
                    UIWindow.enterSwizzleSendEvents()
                }
            }
            .onDisappear{
                if hasListener {
                    UIWindow.exitSwizzleSendEvents()
                }
            }
            .onChangePolyfill(of: hasListener){ old, new in
                if old && !new {
                    UIWindow.exitSwizzleSendEvents()
                } else if !old && new && !isDisabled {
                    UIWindow.enterSwizzleSendEvents()
                }
            }
            .onReceive(WindowEvents.passthrough){ event in
                guard !isDisabled, event.type == .touches, let allTouches = event.allTouches else { return }
                
                let allEnded = allTouches.allSatisfy({ $0.phase == .ended || $0.phase == .cancelled })
                let allStarted = allTouches.allSatisfy({ $0.phase == .began })
            
                if allStarted {
                    started?()
                }
                
                if let changed {
                    changed(allTouches.sorted(by: {
                        $0.estimationUpdateIndex?.intValue ?? 0 < $1.estimationUpdateIndex?.intValue ?? 0
                    }).map{ $0.location(in: nil) })
                }
                
                if allEnded {
                    ended?()
                    changed?([])
                }
            }
        #endif
    }
    
}


public extension View {
    
    func windowInteractionStarted(enabled: Bool = true, _ closure: @escaping () -> Void) -> some View {
        modifier(WindowEventsModifier(started: enabled ? closure : nil))
    }
    
    func windowInteractionEnded(enabled: Bool = true, _ closure: @escaping () -> Void) -> some View {
        modifier(WindowEventsModifier(ended: enabled ? closure : nil))
    }
    
    func windowInteractionChanged(enabled: Bool = true, _ closure: @escaping ([CGPoint]) -> Void) -> some View {
        modifier(WindowEventsModifier(changed: enabled ? closure : nil))
    }
    
}


struct DisableWindowEventsKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


extension EnvironmentValues {
    
    var _disableWindowEvents: Bool {
        get { self[DisableWindowEventsKey.self] }
        set { self[DisableWindowEventsKey.self] = newValue }
    }
    
}


public extension View {
    
    func disableWindowEvents(disable: Bool = true) -> some View {
        environment(\._disableWindowEvents, disable)
    }
    
}
