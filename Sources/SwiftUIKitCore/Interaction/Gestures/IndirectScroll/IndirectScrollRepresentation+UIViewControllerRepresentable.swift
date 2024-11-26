
#if canImport(UIKit)

import SwiftUI

extension IndirectScrollRepresentation : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let ctrl = UIHostingController(rootView: content())
        ctrl.view.backgroundColor = .clear
        context.coordinator.gesture = gesture
        ctrl.view.addGestureRecognizer(context.coordinator.pan)
        return ctrl
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.gesture = gesture
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var gesture: IndirectScrollGesture?
        private var previous: CGPoint = .zero
        private var start = Date()
        
        lazy var pan: UIPanGestureRecognizer = {
            let g = UIPanGestureRecognizer(target: self, action: #selector(panAction))
            g.allowedScrollTypesMask = .continuous
            g.delegate = self
            g.allowedTouchTypes = []
            return g
        }()
        
        @objc func panAction(_ g: UIPanGestureRecognizer) {
            if g.state == .ended || g.state == .cancelled || g.state == .failed {
                gesture?.callEnded(with: .init(
                    time: start.timeIntervalSinceNow,
                    deltaX: 0,
                    deltaY: 0
                ))
                previous = .zero
            } else {
                if g.state == .began {
                    start = Date()
                }
                let t = g.translation(in: nil)
                gesture?.callChanged(with: .init(
                    time: start.timeIntervalSinceNow,
                    deltaX: t.x - previous.x,
                    deltaY: t.y - previous.y
                ))
                
                previous = t
            }
        }
        
    }
    
}

#endif
