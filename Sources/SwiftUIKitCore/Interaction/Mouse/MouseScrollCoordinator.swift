import GameController


@MainActor final class MouseScrollEventCoordinator {
    
    typealias EventHandler = (MouseScrollEvent) -> Void
    typealias Listener = (hash: AnyHashable, handler: EventHandler, window: OSWindow?)
    
    @MainActor static let shared = MouseScrollEventCoordinator()
    
    private var listenerQueue: [Listener] = []
    
    private init(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mouseDidBecomeCurrent),
            name: .GCMouseDidBecomeCurrent,
            object: nil
        )
    }

    func registerListener(key: AnyHashable, _ handler: @escaping EventHandler, in window: OSWindow? = nil) {
        if !listenerQueue.contains(where: { $0.hash == key }) {
            listenerQueue.append((key, handler, window))
        }
    }
    
    func unregisterListener(key: AnyHashable) {
        listenerQueue.removeAll(where: { $0.hash == key })
    }
    
    @objc private func mouseDidBecomeCurrent(_ notification: Notification){
        guard let input = (notification.object as? GCMouse)?.mouseInput else {
            return
        }
        
        input.scroll.valueChangedHandler = { [unowned self] pad, x, y in
            //pad.preferredSystemGestureState = .disabled
            let event = MouseScrollEvent(
                id: UUID().uuidString,
                phase: .changed,
                delta: [Double(x), Double(y)]
            )
            
            for listener in listenerQueue {
                listener.handler(event)
            }
        }
    }
    
}
