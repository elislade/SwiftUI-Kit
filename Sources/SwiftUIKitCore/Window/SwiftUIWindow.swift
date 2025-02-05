import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)


public final class SwiftUIWindow: NSWindow {
    
    let restoreIdentifier: String?
    
    private var intendsToBeMain: Bool = false
    var animationResizeTime: Double = 0.2
    
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { intendsToBeMain }
    
    public init<Content: View>(
        _ restoreIdentifier: String? = nil,
        isMain: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ){
        self.restoreIdentifier = restoreIdentifier
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.intendsToBeMain = isMain
        let contentView = WindowRootView(state: WindowState(self), content: content())
        self.setContentBorderThickness(0, for: .maxX)
        self.contentViewController = NSHostingController(rootView: contentView)
        self.backgroundColor = .clear
    }
    
    public override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
        animationResizeTime
    }
    
}

extension NSWindow.Level {
    
    init(_ index: WindowZIndex) {
        switch index {
        case .normal: self = .normal
        case .normal2: self = .floating
        case .system1: self = .mainMenu
        case .system2: self = .statusBar
        case .systemHighest: self = .screenSaver
        }
    }
    
}

#endif


public enum WindowZIndex: Int, Hashable, CaseIterable, Sendable, BitwiseCopyable {
    case normal = 0
    case normal2 = 1
    case system1 = 2
    case system2 = 3
    case systemHighest = -1
}


struct WindowIndexPreference: PreferenceKey {
    
    static let defaultValue: WindowZIndex? = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let next = nextValue() {
            value = next
        }
    }
    
}


enum WindowStageGrouping: Int, CaseIterable, Sendable, BitwiseCopyable {
    // no special grouping - macOS traditional window grouping. would this also qualify as default of visionOS window grouping?
    case none
    
    // stage manager - macOS, iPadOS stage manager.
    case primary
    
    // fullscreen - macOS fullscreen, iOS & watchOS only has this grouping, on iPadOS this is traditional grouping
    // visionOS would equate to an emersive "Full Space"
    case singular
    
    // fullscreen split - macOS fullscreen split, iPadOS also supports this with split screen.
    case split
}


extension View {
    
    public func windowZIndex(_ index: WindowZIndex) -> some View {
        preference(key: WindowIndexPreference.self, value: index)
    }
    
}

