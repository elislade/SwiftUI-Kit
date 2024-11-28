import SwiftUI

#if canImport(UIKit)

extension KeyPressRepresentation: UIViewRepresentable {
    
    func makeUIView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.keymask = mask
        view.phases = phases
        view.captured = captured
        return view
    }
    
    func updateUIView(_ uiView: KeyCaptureView, context: Context) {
        uiView.keymask = mask
        uiView.phases = phases
        uiView.captured = captured
    }
    
}



final class KeyCaptureView: UIView {

    override var canBecomeFirstResponder: Bool { true }
    
    var keymask: KeyPressPolyfill.MaskType? = nil {
        didSet { pressRecognizer?.mask = keymask }
    }
    
    var phases: KeyPress.Phases = [.down, .repeat] {
        didSet { pressRecognizer?.phases = phases }
    }
    
    var captured: (KeyPress) -> KeyPress.Result = { _ in .ignored } {
        didSet { pressRecognizer?.captured = captured }
    }
    
    weak var pressRecognizer: KeyPressGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        let recognizer = KeyPressGestureRecognizer()
        recognizer.mask = keymask
        recognizer.phases = phases
        recognizer.captured = captured
        addGestureRecognizer(recognizer)
        pressRecognizer = recognizer
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.becomeFirstResponder()
    
    }
    
    
    private func checkForUpPress(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        guard phases.contains(.up) else { return }
        
        if let press = KeyPress(event: event) {
            if let keymask, !keymask(press) {
                return
            }
            
            _ = captured(press)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if let event {
            checkForUpPress(presses, with: event)
        }
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if let event {
            checkForUpPress(presses, with: event)
        }
    }
    
}



@MainActor final class KeyPressGestureRecognizer: UIGestureRecognizer {
    
    var mask: KeyPressPolyfill.MaskType? = nil
    var phases: KeyPress.Phases = [.up, .down, .repeat]
    var captured: (KeyPress) -> KeyPress.Result = { _ in
        return .ignored
    }
    
    var repeatDelay: TimeInterval = 0.5
    var repeatInterval: TimeInterval = 0.1
    
    private var repeatStartWorkItem: DispatchWorkItem?
    private var repeatTimer: Timer?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    override func shouldReceive(_ event: UIEvent) -> Bool {
        guard let event = event as? UIPressesEvent else {
            return false
        }
        
        if let press = KeyPress(event: event), phases.contains(.down) {
            
            if let mask, !mask(press) {
                return false
            }
            
            self.repeatStartWorkItem?.cancel()
            
            if phases.contains(.repeat) {
                let repeatItem = DispatchWorkItem{ [weak self] in
                    guard let self else { return }
                    self.repeatTimer?.invalidate()
                    self.repeatTimer = .scheduledTimer(withTimeInterval: self.repeatInterval, repeats: true){ [weak self] t in
                        DispatchQueue.main.async { [weak self] in
                            if let press = KeyPress(event: event, repeated: true) {
                                _ = self?.captured(press)
                            } else {
                                self?.repeatTimer?.invalidate()
                            }
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + repeatDelay, execute: repeatItem)
                self.repeatStartWorkItem = repeatItem
            }
            
            return captured(press) == .handled
        } else {
            return false
        }
    }
    
}

extension KeyPress {
    
    @MainActor init?(event: UIPressesEvent, repeated: Bool = false){
        let keys = event.allPresses.sorted(by: { $0.timestamp < $1.timestamp }).compactMap(\.key)
        
        // TODO: Report bug to Apple: Caps Lock will not recognize as a persistent modifier with live previews in Xcode, but will work in simulator and on device.
        guard
            let key = keys.last(where: { !$0.charactersIgnoringModifiers.isEmpty }),
            let phase = event.allPresses.compactMap(\.phase).first,
            let keyChar = key.charactersIgnoringModifiers.first,
            let mappedPhase: KeyPress.Phases = .init(phase: phase)
        else {
            print("Fail Press")
            return nil
        }

        if repeated {
            self.phase = mappedPhase.union(.repeat)
        } else {
            self.phase = mappedPhase
        }

        self.modifiers = .init(flags: key.modifierFlags)

        if let keyFromCode = KeyEquivalent(key.keyCode) {
            self.characters = ""
            self.key = keyFromCode
        } else {
            self.key = .init(keyChar)
            self.characters = key.charactersIgnoringModifiers
        }
    }
    
}


extension KeyEquivalent {
    
    init?(_ usage: UIKeyboardHIDUsage) {
        switch usage {
        case .keyboardErrorUndefined: self = .delete
        case .keyboardReturnOrEnter: self = .return
        case .keyboardEscape: self = .escape
        case .keyboardDeleteOrBackspace: self = .delete
        case .keyboardTab: self = .tab
        case .keyboardSpacebar: self = .space
        case .keyboardHome: self = .home
        case .keyboardPageUp: self = .pageUp
        case .keyboardDeleteForward: self = .deleteForward
        case .keyboardEnd: self = .end
        case .keyboardPageDown: self = .pageDown
        case .keyboardRightArrow: self = .rightArrow
        case .keyboardLeftArrow: self = .leftArrow
        case .keyboardDownArrow: self = .downArrow
        case .keyboardUpArrow: self = .upArrow
        case .keypadSlash: self = .delete
        case .keypadEnter: self = .return
        case .keyboardAlternateErase: self = .delete
        case .keyboardClear: self = .clear
        case .keyboardReturn: self = .return
        case .keyboardClearOrAgain: self = .clear
        default: return nil
        }
    }
    
}


extension KeyPress.Phases {
    
    init?(phase: UIPress.Phase) {
        switch phase {
        case .began: self = .down
        case .changed: self = .down
        case .stationary: self = .down
        case .ended: self = .up
        case .cancelled: self = .up
        @unknown default: return nil
        }
    }
    
}


extension EventModifiers {
    
    init(flags: UIKeyModifierFlags) {
        var res = EventModifiers()
        
        if flags.contains(.command){
            res.insert(.command)
        }
        
        if flags.contains(.shift) {
            res.insert(.shift)
        }
        
        if flags.contains(.alphaShift) {
            res.insert(.capsLock)
        }
        
        if flags.contains(.control) {
            res.insert(.control)
        }
        
        if flags.contains(.numericPad) {
            res.insert(.numericPad)
        }
        
        if flags.contains(.alternate){
            res.insert(.option)
        }
        
        self = res
    }
    
}

#endif

