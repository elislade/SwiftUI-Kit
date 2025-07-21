import SwiftUI
import SwiftUIKitCore


public struct DismissPresentationAction: Equatable {
    
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
    
    func handleDismissPresentation(_ action: @MainActor @escaping () -> Void) -> some View {
        InlineState(UUID()){ id in
            InlineEnvironmentReader(\.isBeingPresentedOn){ isBeingPresentedOn in
                self.transformEnvironment(\.dismissPresentation) { value in
                    // only set value if view is not being presented on
                    if isBeingPresentedOn == false {
                        value = .init(id: id, closure: action)
                    }
                }
            }
        }
    }
    
}
