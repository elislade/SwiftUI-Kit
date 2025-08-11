import SwiftUI
import SwiftUIKitCore

struct CoordinatedDismissalModifier {
    
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    @State private var id = UUID()
    
    let action: @MainActor () -> Void
    
    nonisolated init(action: @MainActor @escaping () -> Void) {
        self.action = action
    }
    
}


extension CoordinatedDismissalModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.transformEnvironment(\.coordinatedDismiss) { value in
            // only set value if view is not being presented on
            if isPresentedOn == false {
                value = .init(id: id, closure: action)
            }
        }
    }
    
}
