import SwiftUI

#if canImport(UIKit) && !os(watchOS)

struct PanGestureRepresentable<V: View>: UIViewControllerRepresentable {
    
    var touches: ([InteractionEvent]) -> Void = { _ in }
    
    @ViewBuilder let source: V
    
    func makeUIViewController(context: Context) -> UIViewController {
        let v = UIHostingController(rootView: source)
        v.view.addGestureRecognizer(context.coordinator.pan)
        v.view.backgroundColor = .clear
        return v
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(touches: touches)
    }
    
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        private let touches: ([InteractionEvent]) -> Void
        
        init(touches: @escaping ([InteractionEvent]) -> Void) {
            self.touches = touches
        }
        
        lazy var pan = {
            let g = UIPanGestureRecognizer(
                target: self,
                action: #selector(panAction)
            )
            g.delegate = self
            return g
        }()
        
        
        @objc private func panAction(_ g: UIPanGestureRecognizer) {
            if g.state == .ended || g.state == .cancelled || g.state == .failed {
                touches([])
            } else {
                touches((0..<g.numberOfTouches).map{ i in
                    .init(location: g.location(ofTouch: i, in: nil))
                })
            }
        }
        
        
        // MARK: UIGestureRecognizerDelegate
        
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
    }
    
}


#endif


public extension View {
    
#if os(iOS)
    
    @ViewBuilder func defersSystemGesturesPolyfill(on edges: Edge.Set) -> some View {
        if #available(iOS 16.0, *) {
            self.defersSystemGestures(on: edges)
        } else {
            self
        }
    }
    
#else
    
    func defersSystemGesturesPolyfill(on edges: Edge.Set) -> Self {
        self
    }
    
#endif
    
}
