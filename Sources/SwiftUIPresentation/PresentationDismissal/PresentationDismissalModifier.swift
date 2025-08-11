import SwiftUI
import SwiftUIKitCore

struct PresentationDismissalModifier {
    
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    @State private var id = UUID()
    
    let action: @MainActor () -> Void
    
    nonisolated init(action: @MainActor @escaping () -> Void) {
        self.action = action
    }
    
}

extension PresentationDismissalModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.transformEnvironment(\.dismissPresentation) { value in
            // only set value if view is not being presented on
            if isPresentedOn == false {
                value = .init(id: id, closure: action)
            }
        }
    }
    
}
