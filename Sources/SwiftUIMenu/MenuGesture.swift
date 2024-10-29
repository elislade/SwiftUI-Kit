import SwiftUI
import SwiftUICore

#if canImport(UIKit)

struct MenuGestureRepresentation : UIViewRepresentable {
    
    var delay: TimeInterval = 0.5
    var onChanged: (InteractionEvent) -> Void = { _ in }
    var onEnded: (InteractionEvent) -> Void = { _ in }
    
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.addGestureRecognizer(context.coordinator.long)
        v.addGestureRecognizer(context.coordinator.pan)
        return v
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(delay: delay, onChanged: onChanged, onEnded: onEnded)
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        private let delay: TimeInterval
        private let onChanged: (InteractionEvent) -> Void
        private let onEnded: (InteractionEvent) -> Void
        
        init(
            delay: TimeInterval,
            onChanged: @escaping (InteractionEvent) -> Void,
            onEnded: @escaping (InteractionEvent) -> Void
        ) {
            self.delay = delay
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
        
        lazy var long = {
            let g = UILongPressGestureRecognizer(
                target: self,
                action: #selector(longAction)
            )
            g.minimumPressDuration = delay
            g.delegate = self
            return g
        }()
        
        lazy var pan = {
            let g = UIPanGestureRecognizer(
                target: self,
                action: #selector(panAction)
            )
            g.delegate = self
            return g
        }()
        
        @objc private func longAction(_ g: UILongPressGestureRecognizer) {
            if g.state == .ended {
                onEnded(.init(location: g.location(in: g.view?.window)))
            } else {
                onChanged(.init(location: g.location(in: g.view?.window)))
            }
        }
        
        @objc private func panAction(_ g: UIPanGestureRecognizer) {
            if g.state == .ended || g.state == .cancelled || g.state == .failed {
                onEnded(.init(location: g.location(in: g.view?.window)))
            } else {
                onChanged(.init(location: g.location(in: g.view?.window)))
            }
        }
        
        
        // MARK: UIGestureRecognizerDelegate
        
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer == pan {
                return long.state == .changed
            } else {
                return true
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            
            // if we are panning or the other gesture is some kind of SwiftUI gesture, don't allow it to recognize.
            if gestureRecognizer == pan || type(of: otherGestureRecognizer).description() == "SwiftUI.UIKitGestureRecognizer" {
                return false
            }
            
            return true
        }
        
    }
    
}


#endif
