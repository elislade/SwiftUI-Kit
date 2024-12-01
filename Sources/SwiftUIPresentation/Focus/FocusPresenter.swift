import SwiftUI


struct FocusPresenter<Content: View>: View {
    
    @Binding var isPresented: Bool
    let content: @MainActor () -> Content
    let focusView: @MainActor () -> AnyView
    let accessory: @MainActor (AutoAnchorState) -> AnyView?
    
    nonisolated init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @MainActor @escaping () -> Content,
        focusView: @MainActor @escaping () -> AnyView,
        accessory: @MainActor @escaping (AutoAnchorState) -> AnyView? = { _ in nil }
    ) {
        self._isPresented = isPresented
        self.content = content
        self.focusView = focusView
        self.accessory = accessory
    }
    
    var body: some View {
        content()
            .allowsHitTesting(!isPresented)
            .disabled(isPresented)
            .opacity(isPresented ? 0 : 1)
            .presentationValue(
                isPresented: $isPresented,
                metadata: FocusPresentationMetadata(
                    sourceView: AnyView(content()),
                    accessory: accessory
                )
            ){
                focusView()
            }
    }
    
}
