
#if canImport(AppKit)

import AppKit

final class WindowState: NSObject, ObservableObject {
    
    private unowned let window: NSWindow
    private var previousWindowRadius: CGFloat?
    private var overrideRadius: CGFloat?
    
    @Published private(set) var isKey = false
    @Published private(set) var wantsFullscreen = false
    @Published private(set) var anchor: CGRect = .zero
    
    init(_ window: NSWindow) {
        self.window = window
        self.window.isReleasedWhenClosed = false
        super.init()
        self.window.delegate = self
    }
    
    func set(radius: CGFloat?) {
        guard radius != overrideRadius else { return }
        overrideRadius = radius
        guard !wantsFullscreen else { return }
        
        if let radius {
            previousWindowRadius = window.contentView?.layer?.cornerRadius
            window.contentView?.layer?.cornerRadius = radius
            window.invalidateShadow()
        } else {
            if let previousWindowRadius {
                window.contentView?.layer?.cornerRadius = previousWindowRadius
            }
        }
    }
    
    func onappear() {
        window.invalidateShadow()
    }
    
}


extension WindowState : NSWindowDelegate {
    
    public func windowDidBecomeKey(_ notification: Notification) {
        isKey = true
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        isKey = false
    }
    
    public func windowDidEnterFullScreen(_ notification: Notification) {
        wantsFullscreen = true
        previousWindowRadius = window.contentView?.layer?.cornerRadius
        window.contentView?.layer?.cornerRadius = 0
    }
    
    public func windowDidExitFullScreen(_ notification: Notification) {
        wantsFullscreen = false
        if let radius = overrideRadius ?? previousWindowRadius {
            window.contentView?.layer?.cornerRadius = radius
        }
    }
    
    public func windowDidResize(_ notification: Notification) {

    }
    
}

#endif
