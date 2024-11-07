import SwiftUI
import SwiftUIKitCore


struct AnchorPresenter<PresentationView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    
    var anchorMode: AnchorPresentationMetadata.AnchorMode
    let presentation: (AutoAnchorState) -> PresentationView
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                respondsToBoundsChange: anchorMode == .auto,
                metadata: AnchorPresentationMetadata(
                    anchorMode: anchorMode,
                    view: { AnyView(presentation($0)) }
                ),
                content: {
                    // fallback center based anchor for presentation contexts that may use this other than AlignedContext.
                    AnyView(presentation(.init(anchor: .center, edge: .bottom)))
                }
            )
    }
    
}
