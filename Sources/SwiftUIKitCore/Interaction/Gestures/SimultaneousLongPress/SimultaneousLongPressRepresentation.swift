import SwiftUI


#if canImport(UIKit)

struct SimultaneousLongPressRepresentation : UIViewRepresentable {
    
    var minimumDuration: TimeInterval = 0.3
    var maximumDistance: Double = 10
    var trigger: () -> Void = { }
    
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        context.coordinator.long.minimumPressDuration = minimumDuration
        context.coordinator.trigger = trigger
        context.coordinator.long.allowableMovement = maximumDistance
        v.addGestureRecognizer(context.coordinator.long)
        return v
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.trigger = trigger
        context.coordinator.long.minimumPressDuration = minimumDuration
        context.coordinator.long.allowableMovement = maximumDistance
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var trigger: () -> Void = { }
        
        lazy var long = {
            let g = UILongPressGestureRecognizer(
                target: self,
                action: #selector(longAction)
            )
            g.name = "SwiftUIKitLongPress"
            g.delegate = self
            return g
        }()
        
        @objc private func longAction(_ g: UILongPressGestureRecognizer) {
            if g.state == .began {
                trigger()
            }
        }
        
        // MARK: UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            
            // if the other gesture is some kind of SwiftUI gesture, don't allow it to recognize.
            if gestureRecognizer == long || type(of: otherGestureRecognizer).description() == "SwiftUI.UIKitGestureRecognizer" {
                return false
            }
            
            return true
        }
        
    }
    
}


#endif
