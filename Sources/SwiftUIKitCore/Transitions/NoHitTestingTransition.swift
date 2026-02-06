import SwiftUI


struct HitTestingModifier: ViewModifier {
    
    let enabled: Bool
    
    nonisolated init(enabled: Bool) {
        self.enabled = enabled
    }
    
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(enabled)
            .windowDragDisabled(!enabled)
    }
    
}


extension AnyTransition {
    
    @available(*, deprecated, renamed: "hitTestingDisabled")
    static public var noHitTesting: Self { .hitTestingDisabled }
    
    /// Allows any transition combined with it to not hit test when transitioning, to allow events through immediately instead of waiting for transition to end.
    /// - Note: Useful for transitions that block interactive elements that need to be responsive asap upon removal.
    static public var hitTestingDisabled: Self {
        AnyTransition.modifier(
            active: HitTestingModifier(enabled: false),
            identity: HitTestingModifier(enabled: true)
        )
    }
    
}
