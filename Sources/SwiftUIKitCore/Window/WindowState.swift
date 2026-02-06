
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI

@MainActor final class WindowState: NSObject, ObservableObject {
    
    private let dockTileUpdater = DockTileUpdater()
    private unowned let window: SwiftUIWindow
    private var previousWindowRadius: CGFloat?
    private var overrideRadius: CGFloat?
    private var windowFrameTask: Task<Void, Error>?
    private var persistanceFrameKey: String {
        let id = window.restoreIdentifier ?? "default"
        return"\(id)_windowFrame"
    }
    
    @Published private(set) var phase: ScenePhase = .background
    @Published private(set) var isKey = false
    @Published private(set) var wantsFullscreen = false
    private(set) var anchor: CGRect = .zero
    
    init(_ window: SwiftUIWindow) {
        self.window = window
        self.window.isReleasedWhenClosed = false
        super.init()
        self.window.delegate = self
        self.dockTileUpdater.dockTile = window.dockTile
    }
    
    func perform(action: WindowAction) {
        switch action {
        case let .close(shouldQuit):
            window.close()
            if shouldQuit {
                NSApplication.shared.terminate(nil)
            }
        case .minimize: window.miniaturize(nil)
        case .fullscreen: window.toggleFullScreen(nil)
        case .startMove:
            window.trackEvents(
                matching: [.leftMouseDragged, .leftMouseUp],
                timeout: 0.2,
                mode: .eventTracking
            ){ evt, stop in
                if let evt {
                    if evt.type == .leftMouseUp {
                        stop.pointee = true
                    } else {
                        evt.window?.performDrag(with: evt)
                    }
                }
            }
        case .zoom: window.zoom(nil)
        case let .setFrame(frame, duration):
            if duration > 0 {
                let previousTime = window.animationResizeTime
                window.animationResizeTime = duration
                window.setFrame(frame, display: false, animate: true)
                window.animationResizeTime = previousTime
            } else {
                window.setFrame(frame, display: false, animate: false)
            }
        }
    }
    
    func set(dockTile: DockTilePreference?){
        dockTileUpdater.update(with: dockTile)
    }
    
    func set(positioning: WindowPickerPositioning){
        window.updatePickerPositioning(positioning)
    }
    
    func set(index: WindowZIndex){
        window.level = .init(index)
    }
    
    func setTitle(_ title: String) {
        if window.title != title {
            window.title = title
            NSApplication.shared.changeWindowsItem(window, title: title, filename: false)
        }
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
    
    func restore() {
        if
            let string = UserDefaults.standard.string(forKey: persistanceFrameKey),
            let frame = CGRect(string)
        {
            window.setFrame(frame, display: true)
        }
        
        window.invalidateShadow()
    }
    
}


extension WindowState : NSWindowDelegate {
    
    public func windowDidBecomeKey(_ notification: Notification) {
        isKey = true
        phase = .active
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        isKey = false
    }
    
    func windowWillClose(_ notification: Notification) {
        phase = .inactive
        phase = .background
    }
    
    func windowWillMiniaturize(_ notification: Notification) {
        phase = .inactive
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        phase = .background
    }
    
    public func windowDidResize(_ notification: Notification) {
        windowFrameTask?.cancel()
        windowFrameTask = Task(priority: .low) {
            if let _ = try? await Task.sleep(for: .seconds(2)) {
                UserDefaults.standard.set(window.frame.description, forKey: self.persistanceFrameKey)
            }
        }
    }
    
    func windowDidMove(_ notification: Notification) {
        windowFrameTask?.cancel()
        windowFrameTask = Task(priority: .low) {
            if let _ = try? await Task.sleep(for: .seconds(2)) {
                UserDefaults.standard.set(window.frame.description, forKey: self.persistanceFrameKey)
            }
        }
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
    
}

#endif
