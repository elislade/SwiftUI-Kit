import SwiftUI

#if canImport(AppKit)  && !targetEnvironment(macCatalyst)

extension KeyPressRepresentation: NSViewRepresentable {
    
    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.mask = mask
        view.phases = phases
        view.captured = captured
        return view
    }
    
    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.mask = mask
        nsView.phases = phases
    }
    
}



final class KeyCaptureView: NSView {

    var mask: KeyPressPolyfill.MaskType? = nil
    var phases: KeyPress.Phases = [.down, .repeat]
    var captured: (KeyPress) -> KeyPress.Result = { _ in .ignored }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.window?.makeFirstResponder(self)
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard phases.contains(.down) else { return false }
        
        if event.isARepeat && !phases.contains(.repeat) {
            return false
        }
        
        if let press = KeyPress(event: event) {
            if let mask, !mask(press) {
                return false
            }
            return captured(press) == .handled
        } else {
            return false
        }
    }
    
    override func keyUp(with event: NSEvent) {
        guard phases.contains(.up) else { return }

        if let press = KeyPress(event: event) {
            if let mask, !mask(press) {
                return
            }
            
            _  = captured(press)
        }
    }
    
}


extension KeyPress {
    
    init?(event: NSEvent){
        guard
            let characters = event.charactersIgnoringModifiers,
            let phase = KeyPress.Phases(eventType: event.type)
        else {
            return nil
        }
        
        if event.isARepeat {
            self.phase = phase.union(.repeat)
        } else {
            self.phase = phase
        }
        
        self.characters = characters.lowercased()
        self.modifiers = .init(flags: event.modifierFlags)
 
        if let special = event.specialKey, let key = KeyEquivalent(special: special) {
            self.key = key
        } else if let char = event.characters?.first {
            self.key = .init(char)
        } else {
            return nil
        }
    }
    
}

extension KeyEquivalent {
    
    init?(special: NSEvent.SpecialKey) {
        if special == .delete {
            self = .delete
        } else if special == .deleteForward {
            self = .deleteForward
        } else if special == .tab {
            self = .tab
        } else if special == .upArrow {
            self = .upArrow
        } else if special == .downArrow {
            self = .downArrow
        } else if special == .leftArrow {
            self = .leftArrow
        } else if special == .rightArrow {
            self = .rightArrow
        } else if special == .newline {
            self = .return
        } else if special == .pageUp {
            self = .pageUp
        } else if special == .pageDown {
            self = .pageDown
        } else if special == .clearLine {
            self = .clear
        } else {
            return nil
        }
    }
    
}

extension EventModifiers {
    
    init(flags: NSEvent.ModifierFlags) {
        var res = EventModifiers()
        
        if flags.contains(.shift){
            res.insert(.shift)
        }
        
        if flags.contains(.capsLock){
            res.insert(.capsLock)
        }
        
        if flags.contains(.command) {
            res.insert(.command)
        }
        
        if flags.contains(.control) {
            res.insert(.control)
        }
        
        if flags.contains(.numericPad){
            res.insert(.numericPad)
        }
        
        if flags.contains(.function) {
            res.insert(.function)
        }
        
        self = res
    }
    
}

extension KeyPress.Phases {
    
    init?(eventType: NSEvent.EventType) {
        switch eventType {
        case .leftMouseDown, .rightMouseDown, .keyDown, .otherMouseDown:
            self = .down
        case .leftMouseUp, .rightMouseUp, .keyUp, .otherMouseUp:
            self = .up
        default: return nil
        }
    }
    
}

#endif
