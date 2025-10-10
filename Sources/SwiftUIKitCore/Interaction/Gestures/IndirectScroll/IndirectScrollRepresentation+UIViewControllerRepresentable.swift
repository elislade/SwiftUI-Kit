
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
        
        var gesture: (SIMD2<Double>) -> IndirectScrollGesture? = { _ in nil}
        private var previous: SIMD2<Double> = .zero
        private var start = Date()
        private var activeGesture: IndirectScrollGesture? = nil
        
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
            guard let gesture = activeGesture else { return }
            
            let translation = g.translation(in: nil).simd
            if g.state == .ended || g.state == .cancelled || g.state == .failed {
                gesture.callEnded(with: .init(
                    time: start.timeIntervalSinceNow,
                    delta: .zero,
                    translation: translation
                ))
                activeGesture = nil
                previous = .zero
            } else {
                if g.state == .began {
                    start = Date()
                }
                gesture.callChanged(with: .init(
                    time: start.timeIntervalSinceNow,
                    delta: translation - previous,
                    translation: translation
                ))
                
                previous = translation
            }
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let location = gestureRecognizer.location(in: gestureRecognizer.view?.window)
            activeGesture = gesture(location.simd)
            return activeGesture != nil
        }
        
    }
    
}

#endif
