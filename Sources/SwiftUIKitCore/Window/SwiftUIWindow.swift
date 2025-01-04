
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI

public final class SwiftUIWindow: NSWindow {
    
    private var intendsToBeMain: Bool = false
    
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { intendsToBeMain }
    
    public init<Content: View>(isMain: Bool = false, @ViewBuilder content: @escaping () -> Content){
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 800),
            styleMask: [.closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.intendsToBeMain = isMain
        let contentView = WindowRootView(state: WindowState(self), content: content())
        
        self.collectionBehavior = [.managed, .fullScreenNone, .participatesInCycle]
        self.setContentBorderThickness(0, for: .maxX)
        self.contentViewController = NSHostingController(rootView: contentView)
        //self.contentView?.layer?.borderWidth = 0.2
        //self.contentView?.layer?.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.backgroundColor = .clear
    }
    
}

#endif

