import SwiftUI
import Combine

#if canImport(UIKit)

enum WindowEvents {
    
    static var swizzledReferenceCount: UInt8 = 0
    static var isSwizzled: Bool { swizzledReferenceCount > 0 }
    static let passthrough = PassthroughSubject<UIEvent, Never>()
    
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
                if hasListener {
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
                } else if !old && new {
                    UIWindow.enterSwizzleSendEvents()
                }
            }
            .onReceive(WindowEvents.passthrough){ event in
                guard event.type == .touches, let allTouches = event.allTouches else { return }
                
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



public extension EnvironmentValues {
    
    var lastWindowCoordinatedInteractionLocation: CGPoint? {
        windowCoordinatedInteractionEvents.last?.location
    }
    
}

struct WantsWindowCoordinatedInteractionKey : PreferenceKey {
    
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        if value == false {
            value = nextValue()
        }
    }
    
}

public extension View {
    
    func wantsWindowCoordinatedInteraction(_ flag: Bool = true) -> some View {
        preference(key: WantsWindowCoordinatedInteractionKey.self, value: flag)
    }
    
    func simulatedInteractionEvent(_ value: InteractionEvent?) -> some View {
        preference(key: WindowCoordinationInteractionEventKey.self, value: value != nil ? [value!] : [])
    }
    
    func simulatedInteractionEventsDidChange(_ closure: @escaping ([InteractionEvent]) -> Void) -> some View {
        onPreferenceChange(WindowCoordinationInteractionEventKey.self, perform: closure)
    }
    
    func disableSimulatedInteractionEvents(_ disable: Bool = true) -> some View {
        transformPreference(WindowCoordinationInteractionEventKey.self) { value in
            if disable {
                value = []
            }
        }
    }
    
}


struct WindowCoordinationInteractionEventKey: EnvironmentKey {
    
    static var defaultValue: [InteractionEvent] = []
    
}


extension WindowCoordinationInteractionEventKey: PreferenceKey {
    
    static func reduce(value: inout [InteractionEvent], nextValue: () -> [InteractionEvent]) {
        value.append(contentsOf: nextValue())
    }
    
}


public extension EnvironmentValues {
    
    var windowCoordinatedInteractionEvents: [InteractionEvent] {
        get { self[WindowCoordinationInteractionEventKey.self] }
        set { self[WindowCoordinationInteractionEventKey.self] = newValue }
    }
    
}
