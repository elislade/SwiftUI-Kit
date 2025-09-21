
#if canImport(UIKit) && !os(watchOS)

import SwiftUI

extension IndirectScrollRepresentation : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let ctrl = UIHostingController(rootView: content())
        ctrl.sizingOptions = .preferredContentSize
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
            #if !os(tvOS)
            g.allowedScrollTypesMask = .continuous
            #endif
            g.delegate = self
            g.allowedTouchTypes = []
            return g
        }()
        
        @objc func panAction(_ g: UIPanGestureRecognizer) {
            if g.state == .ended || g.state == .cancelled || g.state == .failed {
                gesture?.callEnded(with: .init(
                    time: start.timeIntervalSinceNow,
                    delta: .zero
                ))
                previous = .zero
            } else {
                if g.state == .began {
                    start = Date()
                }
                let t = g.translation(in: nil)
                gesture?.callChanged(with: .init(
                    time: start.timeIntervalSinceNow,
                    delta: [t.x - previous.x, t.y - previous.y]
                ))
                
                previous = t
            }
        }
        
    }
    
}

#endif
