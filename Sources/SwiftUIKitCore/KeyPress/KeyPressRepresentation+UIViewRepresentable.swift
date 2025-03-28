#if !os(watchOS)

import SwiftUI

#if canImport(UIKit)

extension KeyPressRepresentation: UIViewRepresentable {
    
    func makeUIView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView(frame: .zero)
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
    
    var keymask: KeyPressViewModifier.MaskType? = nil
    var phases: KeyPress.Phases = [.down, .up]
    var captured: (KeyPress) -> KeyPress.Result = { _ in .ignored }
    
    private var repeatDelay: TimeInterval = 0.5
    private var repeatInterval: TimeInterval = 0.1
    private var repeatStartWorkItem: DispatchWorkItem?
    private var repeatTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.becomeFirstResponder()
    }
    
    private func checkForUpPress(_ presses: Set<UIPress>) {
        guard phases.contains(.up) else { return }
        
        for uipress in presses {
            if let press = KeyPress(press: uipress) {
                if let keymask, !keymask(press) {
                    return
                }
                
                _ = captured(press)
            }
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let event else {
            super.pressesBegan(presses, with: event)
            return
        }
        
        if let press = KeyPress(event: event), phases.contains(.down) {
            if let keymask, !keymask(press) {
                super.pressesBegan(presses, with: event)
                return
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
            
            if captured(press) == .ignored {
                super.pressesBegan(presses, with: event)
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        checkForUpPress(presses)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        checkForUpPress(presses)
    }
    
}

extension KeyPress {
    
    @MainActor init?(event: UIPressesEvent, repeated: Bool = false){
        let keys = event.allPresses.sorted(by: { $0.timestamp < $1.timestamp }).compactMap(\.key)
        
        guard
            let key = keys.last(where: { !$0.charactersIgnoringModifiers.isEmpty }),
            let phase = event.allPresses.compactMap(\.phase).first,
            let keyChar = key.characters.first,
            let mappedPhase = KeyPress.Phases(phase: phase)
        else {
            return nil
        }

        if repeated {
            self.phase = mappedPhase.union(.repeat)
        } else {
            self.phase = mappedPhase
        }
        
        self.modifiers = .init(flags: key.modifierFlags)

        if let keyFromCode = KeyEquivalent(key.keyCode) {
            self.characters = key.charactersIgnoringModifiers
            self.key = keyFromCode
        } else {
            self.key = .init(keyChar)
            self.characters = key.charactersIgnoringModifiers
        }
    }
    
    @MainActor init?(press: UIPress, repeated: Bool = false){
        guard
            let key = press.key,
            let keyChar = key.characters.first,
            let mappedPhase = KeyPress.Phases(phase: press.phase)
        else {
            return nil
        }

        if repeated {
            self.phase = mappedPhase.union(.repeat)
        } else {
            self.phase = mappedPhase
        }
        
        self.modifiers = .init(flags: key.modifierFlags)

        if let keyFromCode = KeyEquivalent(key.keyCode) {
            self.characters = key.charactersIgnoringModifiers
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

#endif
