import SwiftUI
import SwiftUIKitCore


extension View {
    
    nonisolated public func presentationMatchContext() -> some View {
        modifier(PresentationMatchContextModifier())
    }
    
    public func presentationMatch(_ id: some Hashable, active: Bool = true) -> some View {
        modifier(PresentationMatchModifier(id: id, active: active, copy: { self }))
    }
    
    nonisolated public func presentationMatchDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.isPresentationMatchEnabled){ value in
            if disabled {
                value = false
            }
        }
    }
    
    nonisolated public func presentationMatchCaptureMode(_ mode: PresentationMatchCaptureMode) -> some View {
        environment(\.presentationMatchCaptureMode, mode)
    }
    
}


extension EnvironmentValues {
    
    @Entry var presentationMatchCaptureMode: PresentationMatchCaptureMode = .newInstance
    @Entry var isInPresentationMatch = false
    @Entry var isPresentationMatchEnabled = true
    
}


/// - Note: It's not recommended to change this often as this changes match view identity meaning it will teardown and setup view when changed.
public enum PresentationMatchCaptureMode: Equatable, Sendable, BitwiseCopyable {
    
    /// Use the current views snapshot image as the match view
    /// - Note: This will result in correct scroll offsets but may miss rendering of some visual effect materials.
    case snapshot
    
    /// Use a new view instance as the match view.
    /// - Note: Good if you care about performance and visual effects and not scroll position or any other ephemeral view state.
    case newInstance
    
}
