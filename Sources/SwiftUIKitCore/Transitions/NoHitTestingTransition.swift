import SwiftUI


struct HitTestingModifier: ViewModifier {
    
    let enabled: Bool
    
    nonisolated init(enabled: Bool) {
        self.enabled = enabled
    }
    
    func body(content: Content) -> some View {
        content.allowsHitTesting(enabled)
    }
}


public extension AnyTransition {
    
    /// NoHitTesting Transition allows any transition combined with it to not hit test when transition to allow events through immediately instead of waiting for transition to end.
    /// - Note: Useful for transitions that block interactive elements that need to be responsive asap upon removal.
    static var noHitTesting: Self {
        AnyTransition.modifier(
            active: HitTestingModifier(enabled: false),
            identity: HitTestingModifier(enabled: true)
        )
    }
    
}
