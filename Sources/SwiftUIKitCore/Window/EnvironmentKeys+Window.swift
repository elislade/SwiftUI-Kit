import SwiftUI


// MARK: Window Action

public enum WindowAction: Sendable {
    case close(shouldQuit: Bool = false)
    case minimize
    case fullscreen
    case zoom
    case translate(CGSize)
    
    static var close: Self { .close() }
}

struct PerformWindowAction: EnvironmentKey {
    
    static var defaultValue: (WindowAction) -> Void { { _ in } }
    
}

extension EnvironmentValues {
    
    // Internal Setter and Getter
    internal var _performWindowAction: (WindowAction) -> Void {
        get { self[PerformWindowAction.self] }
        set { self[PerformWindowAction.self] = newValue }
    }
    
}

public extension EnvironmentValues {
    
    // Public Getter only through computed value
    var performWindowAction: (WindowAction) -> Void { _performWindowAction }
    
}


// MARK: Window Key


struct WindowIsKey: EnvironmentKey {
    static var defaultValue: Bool { true }
}

extension EnvironmentValues {
    
    // Internal Setter and Getter
    internal var _windowIsKey: Bool {
        get { self[WindowIsKey.self] }
        set { self[WindowIsKey.self] = newValue }
    }
    
}

public extension EnvironmentValues {
    
    // Public Getter only through computed value
    var windowIsKey: Bool { _windowIsKey }
    
}
