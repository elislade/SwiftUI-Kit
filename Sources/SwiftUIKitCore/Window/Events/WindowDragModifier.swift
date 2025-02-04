import SwiftUI


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowDragModifier: ViewModifier {
    
    @Environment(\.windowDragEnabled) private var isEnabled
    @State private var windowRef: NSWindow?
    
    var action: (WindowDragEvent) -> Void
    
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

#else

struct WindowDragModifier : ViewModifier {
    
    @Environment(\.windowDragEnabled) private var isEnabled
    @State private var hasStarted: Bool = false
    
    var action: (WindowDragEvent) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            if isEnabled {
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
                            action(.init(phase: .began, locations: locations))
                        }
                        
                        if !allStarted && !allEnded {
                            action(.init(phase: .changed, locations: locations))
                        }
                        
                        if allEnded {
                            action(.init(phase: .ended, locations: locations))
                        }
                    }
                    .hidden()
            }
        }
    }
    
}


#endif
