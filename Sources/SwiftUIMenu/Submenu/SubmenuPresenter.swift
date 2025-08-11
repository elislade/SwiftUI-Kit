import SwiftUI
import SwiftUIPresentation

struct SubmenuPresenter<Label: View, Content: View>: View {
    
    @State private var id = UUID()
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
        .anchorPreference(key: SubmenuPresentationKey.self, value: .bounds){ anchor in
            isPresented ? [
                .init(
                    id: id,
                    anchor: anchor,
                    menu: {
                        AnyView(SubmenuContainer(
                            content: content,
                            label: label
                        ))
                    },
                    dismiss: {
                        Task{ @MainActor in
                            isPresented = false
                        }
                    }
                )
            ] : []
        }
    }
    
    
}
