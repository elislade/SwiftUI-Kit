import SwiftUI


struct ResetActionContext {
    
    @State private var actions: [AsyncResetAction] = []
    
}

extension ResetActionContext: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .environment(\.reset){
                Task {
                    // get unmutable actions copy to make sure actions don't change while resetting.
                    let actions = self.actions
                    for action in actions {
                        await action()
                    }
                }
            }
            .resetActionsChanged{ actions = $0 }
            .resetActionsDisabled()
    }
    
}


public extension EnvironmentValues {
    
    @Entry var reset: () -> Void = { }
    
}
