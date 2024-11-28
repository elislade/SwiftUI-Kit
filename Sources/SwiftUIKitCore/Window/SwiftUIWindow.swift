
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
        self.center()
    }
    
}

public struct StandardTrafficLights: View {
    
    let axis: Axis
    
    public init(axis: Axis = .horizontal) {
        self.axis = axis
        self.isHovering = isHovering
    }
    
    @State private var isHovering = false
    
    public var body: some View {
        AxisStack(axis, spacing: 4) {
            StandardWindowButton(.closeButton, isHighlighted: isHovering)
            StandardWindowButton(.miniaturizeButton, isHighlighted: isHovering)
            StandardWindowButton(.zoomButton, isHighlighted: isHovering)
            StandardWindowButton(.toolbarButton, isHighlighted: isHovering)
            StandardWindowButton(.documentIconButton, isHighlighted: isHovering)
            StandardWindowButton(.documentVersionsButton, isHighlighted: isHovering)
        }
        .onHover{ isHovering = $0 }
    }
    
}

public struct StandardWindowButton: NSViewRepresentable {
    
    let type: NSWindow.ButtonType
    let isHighlighted: Bool
    
    public init(_ type: NSWindow.ButtonType, isHighlighted: Bool = false) {
        self.type = type
        self.isHighlighted = isHighlighted
    }
    
    public func makeNSView(context: Context) -> StandardWindowButtonView {
        StandardWindowButtonView(type: type)
    }
    
    public func updateNSView(_ nsView: StandardWindowButtonView, context: Context) {
        nsView.isHighlighted = isHighlighted
    }
    
}


public final class StandardWindowButtonView: NSView {
    
    let type: NSWindow.ButtonType
    
    var isHighlighted = false {
        didSet {
            if btn != nil {
                btn.isEnabled = isHighlighted
            }
        }
    }
    
    init(type: NSWindow.ButtonType) {
        self.type = type
        super.init(frame: .zero)
        self.widthAnchor.constraint(equalToConstant: 14).isActive = true
        self.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var btn: NSButton!
    
    public override func viewDidMoveToWindow() {
        //self.addTrackingArea(.init(rect: frame, options: [.mouseEnteredAndExited, .activeAlways], owner: self))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){ [unowned self] in
            btn = NSWindow.standardWindowButton(type, for: [.miniaturizable, .closable, .resizable, .docModalWindow])!
            addSubview(btn)
            btn.target = window
            btn.isHighlighted = isHighlighted
        }
    }
    
}
#endif

