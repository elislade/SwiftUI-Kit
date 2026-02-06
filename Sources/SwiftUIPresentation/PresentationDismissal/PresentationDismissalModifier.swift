import SwiftUI
import SwiftUIKitCore

struct PresentationDismissalModifier {
    
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    
    let enabled: Bool
    let handles: DismissalAmount
    let action: @MainActor () -> Void
    
    nonisolated init(
        action: @MainActor @escaping () -> Void,
        handles: DismissalAmount = .once,
        enabled: Bool
    ) {
        self.action = action
        self.enabled = enabled
        self.handles = handles
    }
    
}

extension PresentationDismissalModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.dismissPresentation) { value in
                guard enabled else { return }
                // parent of nil means this is the first so set as all.
                let parent = value
                if parent.amount == nil {
                    value = .init(type: .all){ _ in
                        action()
                    }
                } else {
                    value = .init(type: handles){ amount in
                        if amount == .all {
                            parent(amount)
                        } else if amount == .context && handles == .context {
                            // transform amount to once as the next dismissal will be the context of this one
                            parent(.once)
                        } else {
                            action()
                        }
                    }
                }
        }
    }
    
}
