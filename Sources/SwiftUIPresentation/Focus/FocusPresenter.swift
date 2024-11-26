import SwiftUI


struct FocusPresenter<Content: View>: View {
    
    @Binding var isPresented: Bool
    let content: Content
    let focusView: AnyView
    var accessory: @MainActor (AutoAnchorState) -> AnyView? = { _ in nil }
    
    var body: some View {
        content
            .allowsHitTesting(!isPresented)
            .disabled(isPresented)
            .opacity(isPresented ? 0 : 1)
            .presentationValue(
                isPresented: $isPresented,
                metadata: FocusPresentationMetadata(
                    sourceView: AnyView(content),
                    accessory: accessory
                )
            ){
                focusView
            }
    }
    
}
