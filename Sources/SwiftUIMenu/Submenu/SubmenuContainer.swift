import SwiftUI
import SwiftUIKitCore


struct SubmenuContainer<C: View, L: View> : View {
    
    @Environment(\.coordinatedDismiss) private var dismissCoord
    @Environment(\.dismissPresentation) private var dismiss
    
    @State private var isExpanded = false
    @ViewBuilder let content: @MainActor () -> C
    @ViewBuilder let label: @MainActor () -> L
    
    var body: some View {
        MenuContainer {
            SubmenuLabel(label: label)
                .environment(\._isBeingPresented, isExpanded)
                .handleDismissPresentation {
                    withAnimation(.bouncy){
                        isExpanded = false
                        dismissCoord()
                    }
                }
            
            if isExpanded {
                MenuDivider().transition(.identity)
                content()
            }
        }
        .environment(\.menuVisualDepth, isExpanded ? 1 : 0)
        .onAppear{
            withAnimation(.bouncy){
                isExpanded = true
            }
        }
    }
    
}
