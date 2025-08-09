import SwiftUI


// MARK: Window Action

public enum WindowAction: Sendable {
    case close(shouldQuit: Bool = false)
    case minimize
    case fullscreen
    case zoom
    case startMove
    case setFrame(_ frame: CGRect, duration: TimeInterval = 0.2)
    
    static nonisolated var close: Self { .close() }
}


public extension EnvironmentValues {

    @Entry internal(set) var performWindowAction: (WindowAction) -> Void = { _ in }
    
}


// MARK: Window Key


public extension EnvironmentValues {
    
    @Entry internal(set) var windowIsKey: Bool = true
    
}
