
#if canImport(UIKit) && !os(watchOS)

import SwiftUI

extension IndirectScrollRepresentation : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIHostingController<Source> {
        let ctrl = UIHostingController(rootView: content())
        ctrl.sizingOptions = .preferredContentSize
        ctrl.view.backgroundColor = .clear
        context.coordinator.gesture = gesture
        ctrl.view.addGestureRecognizer(context.coordinator.pan)
        return ctrl
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Source>, context: Context) {
        context.coordinator.gesture = gesture
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: UIHostingController<Source>, context: Context) -> CGSize? {
        uiViewController.sizeThatFits(
            in: proposal.replacingUnspecifiedDimensions(by: CGSizeMake(.infinity, .infinity))
        )
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var gesture: (SIMD2<Double>) -> IndirectScrollGesture? = { _ in nil }
        private var previous: SIMD2<Double> = .zero
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
                    time: Date(),
                    delta: .zero,
                    translation: translation,
                    velocity: g.velocity(in: nil).simd
                ))
                activeGesture = nil
                previous = .zero
            } else {
                if g.state == .began {
                    start = Date()
                }
                gesture.callChanged(with: .init(
                    time: Date(),
                    delta: translation - previous,
                    translation: translation,
                    velocity: g.velocity(in: nil).simd
                ))
                
                previous = translation
            }
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }
            let location = pan.location(in: pan.view?.window)
            let translation = pan.translation(in: nil)
            
            if
                let gesture = gesture(location.simd),
                let axis = translation.simd.greatestMagnitudeAxis,
                gesture.axes.intersects(with: axis.asSet)
            {
                activeGesture = gesture
            } else {
                activeGesture = nil
            }
            return activeGesture != nil
        }
        
    }
    
}

#endif
