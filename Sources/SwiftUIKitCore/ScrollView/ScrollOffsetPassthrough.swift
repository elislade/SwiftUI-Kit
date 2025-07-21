import SwiftUI
@preconcurrency import Combine


public extension View {
    
    /// Any views below this one will have shared access to all scroll offset events in any sibling branches.
    func scrollOffsetContext(enabled: Bool = true) -> some View {
        InlineState(PassthroughSubject<CGPoint, Never>()){ state in
            environment(\.scrollOffsetPassthrough, enabled ? state : nil)
        }
    }
    
    /// Disables any scroll passthrough reading and writing to views below this one.
    func scrollOffsetDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.scrollOffsetPassthrough){ pub in
            if disabled {
                pub = nil
            }
        }
    }
    
}


public extension EnvironmentValues {
    
    @Entry var scrollOffsetPassthrough: PassthroughSubject<CGPoint, Never>? = nil
    
}
