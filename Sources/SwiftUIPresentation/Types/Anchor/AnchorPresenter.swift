import SwiftUI
import SwiftUIKitCore


struct AnchorPresenter<PresentationView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let anchor: AnchorAlignment
    let presentation: @MainActor (AutoAnchorState) -> PresentationView
    
    nonisolated init(
        isPresented: Binding<Bool>,
        anchorMode: AnchorPresentationMetadata.AnchorMode,
        @ViewBuilder presentation: @MainActor @escaping (AutoAnchorState) -> PresentationView
    ) {
        self._isPresented = isPresented
        self.anchor = .init(anchorMode)
        self.presentation = presentation
    }
    
    nonisolated init(
        isPresented: Binding<Bool>,
        anchor: AnchorAlignment,
        @ViewBuilder presentation: @MainActor @escaping (AutoAnchorState) -> PresentationView
    ) {
        self._isPresented = isPresented
        self.anchor = anchor
        self.presentation = presentation
    }
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                respondsToBoundsChange: true,
                metadata: AnchorPresentationMetadata(
                    anchorAlignment: anchor,
                    view: { AnyView(presentation($0)) }
                ),
                content: {
                    // fallback center based anchor for presentation contexts that may use this other than AlignedContext.
                    AnyView(presentation(.init(anchor: .center, edge: .bottom)))
                }
            )
    }
    
}
