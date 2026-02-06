import SwiftUI
import SwiftUIKitCore


struct SubmenuContainer<C: View, L: View> : View {
    
    @Environment(\.coordinatedDismiss) private var dismissCoord
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.isBeingPresentedOn) private var presentedOn
    
    @State private var isExpanded = false
    @ViewBuilder let content: @MainActor () -> C
    @ViewBuilder let label: @MainActor () -> L
    
    var body: some View {
        MenuContainer {
            SubmenuLabel(label: label)
                .environment(\._isBeingPresented, isExpanded)
                .presentationDismissHandler {
                    withAnimation(.bouncy){
                        isExpanded = false
                        dismiss()
                    }
                }
            
            if isExpanded {
                MenuDivider().transition(.identity)
                content().transition(.identity)
            }
        }
        .environment(\.menuVisualDepth, isExpanded ? 1 : 0)
        //.windowInteractionEffects([.squish])
        .task{
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.bouncy){
                isExpanded = true
            }
        }
    }
    
}
