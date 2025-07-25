import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

public struct StandardTrafficLights: View {
    
    let axis: Axis
    
    public init(axis: Axis = .horizontal) {
        self.axis = axis
        self.isHovering = isHovering
    }
    
    @State private var isHovering = false
    
    public var body: some View {
        AxisStack(axis, spacing: 4) {
            StandardWindowButton(.closeButton)
            StandardWindowButton(.miniaturizeButton)
            StandardWindowButton(.zoomButton)
        }
        .onHover{ isHovering = $0 }
        .isHighlighted(isHovering)
    }
    
}


#Preview {
    StandardTrafficLights(axis: .horizontal)
        .padding()
}


public struct StandardWindowButton: NSViewRepresentable {
    
    let type: NSWindow.ButtonType
    
    public init(_ type: NSWindow.ButtonType) {
        self.type = type
    }
    
    public func makeNSView(context: Context) -> StandardWindowButtonView {
        let v = StandardWindowButtonView(type: type)
        v.isHighlighted = context.environment.isHighlighted
        return v
    }
    
    public func updateNSView(_ nsView: StandardWindowButtonView, context: Context) {
        nsView.isHighlighted = context.environment.isHighlighted
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
        Task{ @MainActor [unowned self] in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC / 20)
            btn = NSWindow.standardWindowButton(type, for: [.miniaturizable, .closable, .resizable, .docModalWindow])!
            addSubview(btn)
            btn.target = window
            btn.isHighlighted = isHighlighted
        }
    }
    
}

#endif
