import SwiftUI


public struct PanGestureState: Hashable, Sendable, BitwiseCopyable {
    
    public enum Phase: Hashable, Sendable, BitwiseCopyable {
        case began
        case changed
        case ended
    }
    
    public let phase: Phase
    public let translation: SIMD2<Double>
}

#if canImport(UIKit) && !os(watchOS)

extension PanGestureState.Phase {
    init?(_ state: UIGestureRecognizer.State) {
        switch state {
        case .possible: return nil
        case .began: self = .began
        case .changed: self = .changed
        case .ended: self = .ended
        case .cancelled: self = .ended
        case .failed: return nil
        @unknown default: return nil
        }
    }
}

struct PanGestureRepresentation : UIViewRepresentable {
    
    var minimumNumberOfTouches: Int = 1
    var maximumNumberOfTouches: Int = 2
    
    var update: (PanGestureState) -> Void = { _ in }
    
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        context.coordinator.update = update
        #if !os(tvOS)
        context.coordinator.gesture.minimumNumberOfTouches = minimumNumberOfTouches
        context.coordinator.gesture.maximumNumberOfTouches = maximumNumberOfTouches
        #endif
        v.addGestureRecognizer(context.coordinator.gesture)
        return v
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.update = update
        #if !os(tvOS)
        context.coordinator.gesture.minimumNumberOfTouches = minimumNumberOfTouches
        context.coordinator.gesture.maximumNumberOfTouches = maximumNumberOfTouches
        #endif
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var update: (PanGestureState) -> Void = { _ in }
        
        lazy var gesture = {
            let g = UIPanGestureRecognizer(
                target: self,
                action: #selector(_update)
            )
            g.name = "SwiftUIKitPan"
            g.delegate = self
            return g
        }()
        
        @objc private func _update(_ g: UIPanGestureRecognizer) {
            if let validPhase = PanGestureState.Phase(g.state){
                let translation = g.translation(in: nil)
                update(.init(
                    phase: validPhase,
                    translation: [translation.x, translation.y]
                ))
            }
        }
        
        // MARK: UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            
            // if the other gesture is some kind of SwiftUI gesture, don't allow it to recognize.
            if gestureRecognizer == gesture || type(of: otherGestureRecognizer).description() == "SwiftUI.UIKitGestureRecognizer" {
                return false
            }
            
            return true
        }
        
    }
    
}


#endif
