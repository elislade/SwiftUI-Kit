#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI

final class IndirectScrollView<Source: View> : NSHostingView<Source> {
    
    var gesture: IndirectScrollGesture?
    
    required init(rootView: Source) {
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let gesture, event.type == .scrollWheel else { return }
        
        if gesture.useMomentum {
            if event.phase == .began || event.phase == .changed || event.momentumPhase == .changed {
                gesture.callChanged(with: .init(event))
            } else if (event.phase == .ended && event.momentumPhase.rawValue == 0) || event.momentumPhase == .ended {
                gesture.callEnded(with: .init(event))
            }
        } else {
            if event.phase == .began || event.phase == .changed {
                gesture.callChanged(with: .init(event))
            } else if event.phase == .ended {
                gesture.callEnded(with: .init(event))
            }
        }
    }
    
}


extension IndirectScrollGesture.Value {
    
    init(_ event: NSEvent) {
        self.time = event.timestamp
        self.deltaX = event.scrollingDeltaX
        self.deltaY = event.scrollingDeltaY
    }
    
}

extension IndirectScrollRepresentation : NSViewRepresentable {
    
    func makeNSView(context: Context) -> IndirectScrollView<Source> {
        let view = IndirectScrollView(rootView: content())
        view.gesture = gesture
        return view
    }
    
    func updateNSView(_ nsView: IndirectScrollView<Source>, context: Context) {
        nsView.gesture = gesture
    }
    
}

#endif
