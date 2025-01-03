import SwiftUI


public extension View {
    
    func windowInteraction(
        started: @escaping ([CGPoint]) -> Void = { _ in },
        changed: @escaping ([CGPoint]) -> Void = { _ in },
        ended: @escaping ([CGPoint]) -> Void = { _ in }
    ) -> some View {
        modifier(WindowEventsModifier(
            started: started,
            changed: changed,
            ended: ended
        ))
    }
    
}


struct DisableWindowEventsKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


extension EnvironmentValues {
    
    var _disableWindowEvents: Bool {
        get { self[DisableWindowEventsKey.self] }
        set { self[DisableWindowEventsKey.self] = newValue }
    }
    
}


public extension View {
    
    func disableWindowEvents(_ disabled: Bool = true) -> some View {
        environment(\._disableWindowEvents, disabled)
    }
    
}
