import SwiftUI
import Combine
import OSLog

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

struct WindowEventsModifier : ViewModifier {
    
    @Environment(\._disableWindowEvents) private var isDisabled
    @State private var hasStarted: Bool = false
    
    var started: @MainActor ([CGPoint]) -> Void
    var changed: @MainActor ([CGPoint]) -> Void
    var ended: @MainActor ([CGPoint]) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            if !isDisabled {
                Color.clear
                    .onAppear{ UIWindow.enterSwizzleSendEvents() }
                    .onDisappear{ UIWindow.exitSwizzleSendEvents() }
                    .onReceive(WindowEvents.passthrough
                        .filter({ $0.type == .touches })
                        .compactMap(\.allTouches)
                        // Order contains the order of the touches, while sorted is the current touches following that order. Sorted will be sorted on every pass while the order changes only on begin and end phases of individual touches.
                        .scan((order: [UITouch](), sorted: [UITouch]())) { state, current in
                            var order = state.order
                            for touch in current {
                                if !order.contains(touch) {
                                    order.append(touch)
                                }
                            }

                            let sorted:[UITouch] = order.isEmpty ? [] : current.sorted(by: {
                                return order.firstIndex(of: $0)! < order.firstIndex(of: $1)!
                            })
                            
                            var indicesToRemove: IndexSet = []
                            
                            for touch in current {
                                if let index = order.firstIndex(of: touch), touch.phase == .ended || touch.phase == .cancelled {
                                    indicesToRemove.insert(index)
                                }
                            }
                            
                            order.remove(atOffsets: indicesToRemove)

                            return (order, sorted)
                        }
                        .map{ $0.sorted }
                    ){ touches in
                        let allEnded = touches.allSatisfy({ $0.phase == .ended || $0.phase == .cancelled })
                        let allStarted = touches.allSatisfy({ $0.phase == .began })
                        let locations = touches.map{ $0.location(in: nil) }
                    
                        if allStarted {
                            //print("Started")
                            started(locations)
                        }
                        
                        if !allStarted && !allEnded {
                            changed(locations)
                        }
                        
                        if allEnded {
                            //print("Ended")
                            ended(locations)
                        }
                    }
                    .hidden()
            }
        }
    }
    
}


struct WindowHoverModifier: ViewModifier {
    
    @Environment(\._disableWindowEvents) private var isDisabled
    
    var hover: @MainActor (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            if !isDisabled {
                Color.clear
                    .onAppear{ UIWindow.enterSwizzleSendEvents() }
                    .onDisappear{ UIWindow.exitSwizzleSendEvents() }
                    .onReceive(WindowEvents.passthrough){ event in
                        guard
                            event.type == .hover,
                            let touch = event.allTouches?.first(where: { $0.type != .direct })
                        else { return }
                        
                        hover(touch.location(in: nil))
                    }
            }
        }
    }
    
}

#endif

