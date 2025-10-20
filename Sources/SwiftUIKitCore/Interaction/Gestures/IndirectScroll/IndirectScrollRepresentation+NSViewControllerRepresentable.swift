#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI

extension IndirectScrollRepresentation : NSViewControllerRepresentable {
    
    func makeNSViewController(context: Context) -> IndirectScrollViewController<Source> {
        let ctrl = IndirectScrollViewController(rootView: content())
        ctrl.gesture = gesture
        return ctrl
    }
    
    func updateNSViewController(_ nsViewController: IndirectScrollViewController<Source>, context: Context) {
        nsViewController.gesture = gesture
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, nsViewController: IndirectScrollViewController<Source>, context: Context) -> CGSize? {
        nsViewController.sizeThatFits(
            in: proposal.replacingUnspecifiedDimensions(by: CGSizeMake(.infinity, .infinity))
        )
    }
    
}


final class IndirectScrollViewController<Source: View> : NSHostingController<Source> {
    
    var gesture: (@MainActor (SIMD2<Double>) -> IndirectScrollGesture?) = { _ in nil }
    
    private var inflectionEventA: NSEvent?
    private var inflectionEventB: NSEvent?
    private var activeGesture: IndirectScrollGesture?
    private var totalTranslation: SIMD2<Double> = .zero
    
    private func velocity() -> SIMD2<Double> {
        guard let inflectionEventB, let inflectionEventA else { return .zero }
        let timeStep = inflectionEventB.timestamp - inflectionEventA.timestamp
        return inflectionEventB.scrollDelta * (0.1 / timeStep)
    }
    
    override func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
        true
    }
    
    override func scrollWheel(with event: NSEvent) {
        
        if event.phase == .began {
            if
                let gesture = gesture(event.flippedYLocationInWindow.simd),
                let axis = event.scrollDelta.greatestMagnitudeAxis,
                gesture.axes.intersects(with: axis.asSet)
            {
                activeGesture = gesture
            }
            
            totalTranslation = .zero
        }
        
        defer {
            if event.phase == .ended || event.phase == .cancelled {
                activeGesture = nil
            }
        }
        
        guard let gesture = activeGesture, !gesture.axes.isEmpty else {
            super.scrollWheel(with: event)
            return
        }
        
        totalTranslation += event.scrollDelta
        
        let resolved = IndirectScrollGesture.Value(
            time: Date(),
            delta: event.scrollDelta,
            translation: totalTranslation,
            velocity: velocity()
        )
        
        inflectionEventA = inflectionEventB
        inflectionEventB = event
        
        if event.phase == .began {
            gesture.callChanged(with: resolved)
        } else if event.phase == .changed {
            gesture.callChanged(with: resolved)
        } else if event.phase == .ended {
            gesture.callEnded(with: resolved)
        }
    }
    
}

extension NSEvent {
    
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


extension NSView {
    
    func enumerate(closure: @escaping (NSView) -> Bool) {
        for child in subviews {
            guard closure(child) else { return }
        }
        
        for child in subviews {
            child.enumerate(closure: closure)
        }
    }
    
}

#endif
