import SwiftUI
import SwiftUIKitCore


public extension View {
    
    nonisolated func presentationMatchContext() -> some View {
        modifier(PresentationMatchContextModifier())
    }
    
    func presentationMatch<ID: Hashable>(_ id: ID) -> some View {
        modifier(PresentationMatchModifier(id: id, copy: { self }))
    }
    
    nonisolated func presentationMatchCaptureMode(_ mode: PresentationMatchCaptureMode) -> some View {
        environment(\.presentationMatchCaptureMode, mode)
    }
    
}


extension EnvironmentValues {
    
    @Entry var presentationMatchCaptureMode: PresentationMatchCaptureMode = .newInstance
    
}


/// - Note: It's not recommended to change this often as this changes match view identity meaning it will teardown and setup view when changed.
public enum PresentationMatchCaptureMode: Equatable, Sendable, BitwiseCopyable {
    
    /// Use the current views snapshot image as the match view
    /// - Note: This will result in correct scroll offsets but may miss rendering of some visual effect materials.
    case snapshot
    
    /// Use a new view instance as the match view.
    /// - Note: Good if you care about performace and visual effects and not scroll position or any other ephemeral view state.
    case newInstance
    
}
