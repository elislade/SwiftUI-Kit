import SwiftUI


#if os(iOS) || os(visionOS) || os(tvOS)

struct WindowDragModifier {
    
    @Environment(\.windowDragEnabled) private var isEnabled
    @State private var hasStarted: Bool = false
    @State private var window: UIWindow?
    
    let action: (WindowDragEvent) -> Void
    
}

extension WindowDragModifier : ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .windowReference{ window = $0 }
            .overlay {
                ZStack {
                    if isEnabled {
                        Color.clear
                            .onAppear{ UIWindow.enterSwizzleSendEvents() }
                            .onDisappear{ UIWindow.exitSwizzleSendEvents() }
                            .onReceive(WindowEvents.passthrough
                                .filter({ $0.type == .touches && isEnabled })
                                .compactMap{
                                    if let window {
                                        $0.touches(for: window)
                                    } else {
                                        $0.allTouches
                                    }
                                }
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
            .disableAnimations()
        }
    }
}

#endif
