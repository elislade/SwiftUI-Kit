import GameController
import Combine


@MainActor final class MouseClickEventCoordinator {
    
    typealias EventHandler = (MouseClickEvent) -> Void
    typealias Listener = (hash: AnyHashable, handler: EventHandler, window: OSWindow?)
    
    @MainActor static let shared = MouseClickEventCoordinator()
    
    private var listenerQueue: [Listener] = []
    private var iOSMouseLocation: CGPoint? = nil
    private var windowEventsCancellable: AnyCancellable?
    
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
        
        if listenerQueue.isEmpty {
            windowEventsCancellable?.cancel()
            windowEventsCancellable = nil
        }
    }
    
    private func location(for listener: Listener) -> SIMD2<Double>? {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        if let point = listener.window?.currentEvent?.flippedYLocationInWindow {
            return [point.x, point.y]
        } else {
            return nil
        }
        #else
        return nil
        #endif
    }
    
    private func handle(button: MouseClickEvent.Button, pressed: Bool) {
        if let listener = listenerQueue.first {
            listener.handler(MouseClickEvent(
                id: UUID().uuidString,
                button: button,
                phase: pressed ? .down : .up,
                location: location(for: listener)
            ))
        }
    }
    
    @objc private func mouseDidBecomeCurrent(_ notification: Notification){
        guard let input = (notification.object as? GCMouse)?.mouseInput else {
            return
        }
        
        input.leftButton.pressedChangedHandler = { [unowned self] _, _, pressed in
            handle(button: .left, pressed: pressed)
        }
        
        input.rightButton?.pressedChangedHandler = { [unowned self] _, _, pressed in
            handle(button: .right, pressed: pressed)
        }
        
        input.middleButton?.pressedChangedHandler = { [unowned self] _, _, pressed in
            handle(button: .middle, pressed: pressed)
        }
        
        for auxiliaryButton in input.auxiliaryButtons ?? [] {
            auxiliaryButton.pressedChangedHandler = { [unowned self] _, _, pressed in
                handle(button: .other, pressed: pressed)
            }
        }
    }
    
}
