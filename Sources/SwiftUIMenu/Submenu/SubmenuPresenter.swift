import SwiftUI
import SwiftUIPresentation

struct SubmenuPresenter<Label: View, Content: View>: View {
    
    @State private var isPresented = false
    
    @ViewBuilder let label: @MainActor() -> Label
    @ViewBuilder let content: @MainActor() -> Content
    
    private func present() {
        isPresented = true
    }
    
    var body: some View {
        SubmenuLabel(
            isStandalone: true,
            action: present,
            label: label
        )
        .opacity(isPresented ? 0 : 1)
        .animation(.smooth, value: isPresented)
        .presentationValue(
            isPresented: $isPresented,
            respondsToBoundsChange: true,
            metadata: SubmenuMetadata()
        ){
            SubmenuContainer(
                content: content,
                label: label
            )
        }
    }
    
    
}
