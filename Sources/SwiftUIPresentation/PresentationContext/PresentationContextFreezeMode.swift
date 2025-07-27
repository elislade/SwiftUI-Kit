import SwiftUI
import SwiftUIKitCore

/// The `FrozenState` to use once the presentation has finished presenting over the context.
/// Only use `frozenInvisable` if the `PresentationBackdrop` will be opaque or the presentation view will cover the context with `.frame(maxWidth: .infinity, maxHeight: .infinity)`
public enum PresentationContextFreezeMode {
    
    /// The context decides the frozen state.
    case auto
    
    /// The presenter explicity decides the state.
    case explicit(FrozenState)
}


extension EnvironmentValues {
    
    @Entry var presentaionContextFreezeMode: PresentationContextFreezeMode = .auto
    
}
