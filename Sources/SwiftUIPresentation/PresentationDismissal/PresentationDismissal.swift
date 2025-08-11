import SwiftUI
import SwiftUIKitCore


public struct DismissPresentationAction: Equatable, Sendable {
    
    public static func == (lhs: DismissPresentationAction, rhs: DismissPresentationAction) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let closure: @MainActor () -> Void
    
    public init(id: UUID = .init(), closure: @MainActor @escaping () -> Void) {
        self.id = id
        self.closure = closure
    }
    
    @MainActor public func callAsFunction() {
        closure()
    }
    
}

public extension EnvironmentValues {
    
    @Entry var dismissPresentation: DismissPresentationAction = .init(closure: {})
    
    /// Similar to dismiss but infers that it wants to be coordinated with another dismissal lower down in the view tree.
    /// - NOTE: This means it should only be removed on topmost coordinator at the end of the transaction.
    @Entry var coordinatedDismiss: DismissPresentationAction = .init(closure: {})
    
}

public extension View {
    
    nonisolated func handleDismissPresentation(_ action: @MainActor @escaping () -> Void) -> some View {
        modifier(PresentationDismissalModifier(action: action))
    }
    
    nonisolated func onCoordinatedDismiss(perform action: @MainActor @escaping () -> Void) -> some View {
        modifier(CoordinatedDismissalModifier(action: action))
    }
    
}
