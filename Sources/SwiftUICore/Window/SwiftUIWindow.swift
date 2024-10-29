
#if canImport(AppKit)

import SwiftUI
import AppKit

public final class SwiftUIWindow: NSWindow {
    
    public static let defaultRadius: CGFloat = 16
    
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
    
    public init<Content: View>(@ViewBuilder content: @escaping () -> Content){
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 800),
            styleMask: [.closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
      
        let contentView = WindowRootView(state: WindowState(self), content: content())
            .onPreferenceChange(WindowTitleKey.self){ [unowned self] wrappedValue in
                title = wrappedValue.last ?? ""
            }
            .environment(\._performWindowAction){ [unowned self] onChanged in
                switch onChanged {
                case .close: close()
                case .minimize: miniaturize(nil)
                case .fullscreen: toggleFullScreen(nil)
                case .translate(let translation):
                    let newFrame = frame.offsetBy(dx: translation.width, dy: -(translation.height / 2))
                    setFrame(newFrame, display: true)
                }
            }
        
        self.collectionBehavior = [.fullScreenNone, .participatesInCycle]
        self.setContentBorderThickness(0, for: .maxX)
        self.contentViewController = NSHostingController(rootView: contentView)
        self.contentView?.layer?.borderWidth = 0.2
        self.contentView?.layer?.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.contentView?.layer?.cornerRadius = Self.defaultRadius
        self.backgroundColor = .clear
        self.center()
    }
    
}

#endif

