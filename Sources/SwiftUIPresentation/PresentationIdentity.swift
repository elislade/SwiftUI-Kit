import SwiftUI



/// `PresentationIdentityBehaviour` gives control over how presentation id is to be handled. By default most implimentations should use `.stable` as default as it's most performant.
/// - Note: Since presentation views are type erased to `AnyView` it's recommended that all state needed for a presentation view be inside of it or passed to it through a binding as this will **NOT** be effected by the `AnyView` type eraser. Doing this along with `.stable` behaviour will lead to the most performant presentation.  If you use `.changeOnUpdate` behaviour you don't need to worry about the presentation view wrapping its own state, so you can pass state through normal let vars and from values in the view managing the presentation, but with a tradeoff that the preference key delivering this presentation will re-evaluate on every view update even if the view has no state changes.
/// - Note: This behaviour is only for id of the presentation preference if any other component of the preference value changes such as `tag`, `anchor`, or `metadata`, the view will be re-evaluated.
public enum PresentationIdentityBehaviour: Hashable {
    
    /// The presentation id will only update on view setup.
    /// - Note: This is the most performant out of all the options as the presentation id for the preference key will be updated once.
    case stable
    
    /// The presentation id will update on every view update cycle.
    /// - Note: This is the least performant as it will update when any view updates are detected.
    case changeOnUpdate
    
    /// The presentation id will change with a custom hashable value.
    /// - Note: Performance is dependant on how often the Hashable value is updated.
    case custom(AnyHashable)
    
    
    public var customHashable: AnyHashable? {
        if case .custom(let anyHashable) = self {
            return anyHashable
        } else { return nil }
    }
    
    
    public var isStable: Bool { self == .stable }
    
}


struct PresentationIdentityBehaviourKey: EnvironmentKey {
    
    static var defaultValue: PresentationIdentityBehaviour { .stable }
    
}


extension EnvironmentValues {
    
    public var presentationIdentityBehaviour: PresentationIdentityBehaviour {
        get { self[PresentationIdentityBehaviourKey.self] }
        set { self[PresentationIdentityBehaviourKey.self] = newValue }
    }
    
}


public extension View {
    
    nonisolated func presentationIdentityBehaviour(_ presentationIdentityBehaviour: PresentationIdentityBehaviour) -> some View {
        environment(\.presentationIdentityBehaviour, presentationIdentityBehaviour)
    }
    
}
