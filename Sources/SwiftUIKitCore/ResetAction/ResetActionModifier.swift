import SwiftUI

struct ResetActionModifier: ViewModifier {
    
    @Environment(\.frozenState) private var frozenState
    @State private var id = UUID()
    
    let active: Bool
    let action: @MainActor () -> Void
    
    func body(content: Content) -> some View {
        content
            .transformPreference(ResetActionKey.self){ resetAction in
                if active, resetAction == nil, frozenState.isThawed {
                    resetAction = .init(id: id, action: action)
                }
            }
    }
    
}
