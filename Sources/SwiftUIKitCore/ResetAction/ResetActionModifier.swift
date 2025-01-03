import SwiftUI

struct ResetActionModifier: ViewModifier {
    
    @State private var id = UUID()
    
    let active: Bool
    let action: @MainActor () -> Void
    
    func body(content: Content) -> some View {
        content
            .transformPreference(ResetActionKey.self){ resetAction in
                if active, resetAction == nil {
                    resetAction = .init(id: id, action: action)
                }
            }
    }
    
}
