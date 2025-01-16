#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI


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


final class IndirectScrollView<Source: View> : NSHostingView<Source> {
    
    var gesture: IndirectScrollGesture?

    required init(rootView: Source) {
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var lockedMaskDelta: SIMD2<Double>?
    private var hasStartedScrolling: Bool = false
    
    override func scrollWheel(with event: NSEvent) {
        guard let gesture, !gesture.mask.isEmpty else {
            super.scrollWheel(with: event)
            return
        }
        
        if event.phase == .began {
            hasStartedScrolling = true
            lockedMaskDelta = nil
        }
        
        var evaluateMaskDelta: SIMD2<Double>
        
        switch gesture.maskEvaluation {
        case .continuous:
            evaluateMaskDelta = [event.scrollingDeltaX, event.scrollingDeltaY]
        case .locked:
            if let lockedMaskDelta {
                evaluateMaskDelta = lockedMaskDelta
            } else {
                evaluateMaskDelta = [event.scrollingDeltaX, event.scrollingDeltaY]
                lockedMaskDelta = evaluateMaskDelta
            }
        }
     
        let shouldIgnoreX = gesture.mask == .horizontal && evaluateMaskDelta.x.rounded(.towardZero) == 0
        let shouldIgnoreY = gesture.mask == .vertical && evaluateMaskDelta.y.rounded(.towardZero) == 0
        
        if shouldIgnoreX || shouldIgnoreY {
            super.scrollWheel(with: event)
            if hasStartedScrolling {
                if event.hasEnded(usingMomentum: gesture.useMomentum) {
                    gesture.callEnded(with: .init(event, for: gesture.mask, flipX: userInterfaceLayoutDirection == .rightToLeft))
                    hasStartedScrolling = false
                }
            }
            return
        }
        
        if event.hasBegan(usingMomentum: gesture.useMomentum) {
            gesture.callChanged(with: .init(event, for: gesture.mask, flipX: userInterfaceLayoutDirection == .rightToLeft))
        } else if event.hasChanged(usingMomentum: gesture.useMomentum) {
            if hasStartedScrolling {
                gesture.callChanged(with: .init(event, for: gesture.mask, flipX: userInterfaceLayoutDirection == .rightToLeft))
            } else {
                super.scrollWheel(with: event)
            }
        } else if event.hasEnded(usingMomentum: gesture.useMomentum) {
            if hasStartedScrolling {
                gesture.callEnded(with: .init(event, for: gesture.mask, flipX: userInterfaceLayoutDirection == .rightToLeft))
                hasStartedScrolling = false
            } else {
                super.scrollWheel(with: event)
            }
        }
    }
    
}

extension NSEvent {
    
    func hasBegan(usingMomentum: Bool) -> Bool {
        phase == .began
    }
    
    func hasChanged(usingMomentum: Bool) -> Bool {
        usingMomentum ? phase == .changed || momentumPhase == .changed : phase == .changed
    }
    
    func hasEnded(usingMomentum: Bool) -> Bool {
        usingMomentum ? (phase == .ended && momentumPhase.rawValue == 0) || momentumPhase == .ended : phase == .ended
    }
    
}

extension NSEvent.GestureAxis {
    
    init(_ axis: Axis?){
        if let axis = axis {
            switch axis {
            case .horizontal: self = .horizontal
            case .vertical: self = .vertical
            }
        } else {
            self = .none
        }
    }
    
}

extension Axis {
    
    init?(_ axis: NSEvent.GestureAxis){
        switch axis {
        case .horizontal: self = .horizontal
        case .vertical: self = .vertical
        case .none: return nil
        @unknown default: return nil
        }
    }
    
}

extension Axis.Set {
    
    init(_ axis: NSEvent.GestureAxis){
        switch axis {
        case .horizontal: self = .horizontal
        case .vertical: self = .vertical
        case .none: self = []
        @unknown default: self = []
        }
    }
    
}

extension IndirectScrollGesture.Value {
    
    init(_ event: NSEvent, for axis: Axis.Set = [.horizontal, .vertical], flipX: Bool = false) {
        self.time = event.timestamp
        self.delta = [
            axis.contains(.horizontal) ? event.scrollingDeltaX * (flipX ? -1 : 1) : 0,
            axis.contains(.vertical) ? event.scrollingDeltaY : 0
        ]
    }
    
}

#endif
