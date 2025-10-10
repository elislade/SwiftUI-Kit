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
    
    var gesture: (@MainActor (SIMD2<Double>) -> IndirectScrollGesture?) = { _ in nil }

    required init(rootView: Source) {
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var activeGesture: IndirectScrollGesture?
    private var lockedMaskDelta: SIMD2<Double>?
    private var hasStartedScrolling: Bool = false
    private var totalTranslation: SIMD2<Double> = .zero
    
    override func scrollWheel(with event: NSEvent) {
        if event.phase == .mayBegin || event.phase == .began {
            activeGesture = gesture(event.flippedYLocationInWindow.simd)
        }
        
        guard let gesture = activeGesture, !gesture.mask.isEmpty else {
            super.scrollWheel(with: event)
            return
        }
        
        defer {
            if event.phase == .ended || event.phase == .cancelled {
                activeGesture = nil
            }
        }
        
        if event.phase == .began {
            hasStartedScrolling = true
            lockedMaskDelta = nil
            totalTranslation = .zero
        }
        
        if event.phase == .changed {
            totalTranslation += event.scrollDelta
        }
        
        var evaluateMaskDelta: SIMD2<Double>
        
        switch gesture.maskEvaluation {
        case .onChange:
            evaluateMaskDelta = event.scrollDelta
        case .onBegin:
            if let lockedMaskDelta {
                evaluateMaskDelta = lockedMaskDelta
            } else {
                evaluateMaskDelta = event.scrollDelta
                lockedMaskDelta = evaluateMaskDelta
            }
        }
     
        let shouldIgnoreX = gesture.mask == .horizontal && evaluateMaskDelta.x.rounded(.towardZero) == 0
        let shouldIgnoreY = gesture.mask == .vertical && evaluateMaskDelta.y.rounded(.towardZero) == 0
        
        let resolved = IndirectScrollGesture.Value(
            event,
            for: gesture.mask,
            flipX: userInterfaceLayoutDirection == .rightToLeft,
            totalTranslation: totalTranslation
        )
        
        if shouldIgnoreX || shouldIgnoreY {
            super.scrollWheel(with: event)
            if hasStartedScrolling {
                if event.hasEnded(usingMomentum: gesture.useMomentum) {
                    gesture.callEnded(with: resolved)
                    hasStartedScrolling = false
                }
            }
            return
        }
        
        if event.hasBegan(usingMomentum: gesture.useMomentum) {
            gesture.callChanged(with: resolved)
        } else if event.hasChanged(usingMomentum: gesture.useMomentum) {
            if hasStartedScrolling {
                gesture.callChanged(with: resolved)
            } else {
                super.scrollWheel(with: event)
            }
        } else if event.hasEnded(usingMomentum: gesture.useMomentum) {
            if hasStartedScrolling {
                gesture.callEnded(with: resolved)
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
    
    var scrollDelta: SIMD2<Double> {
        [scrollingDeltaX, scrollingDeltaY]
    }
    
}

extension NSEvent.GestureAxis {
    
    init(_ axis: Axis?){
        if let axis {
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
    
    init(
        _ event: NSEvent,
        for axis: Axis.Set = [.horizontal, .vertical],
        flipX: Bool = false,
        totalTranslation: SIMD2<Double>
    ) {
        self.time = event.timestamp
        self.delta = [
            axis.contains(.horizontal) ? event.scrollingDeltaX * (flipX ? -1 : 1) : 0,
            axis.contains(.vertical) ? event.scrollingDeltaY : 0
        ]
        
        self.translation = totalTranslation
    }
    
}

#endif
