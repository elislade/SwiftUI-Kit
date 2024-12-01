import SwiftUI
import SwiftUIKitCore


public extension View {
    
    
    /// Defines an anchor presentation context for children to present in.
    /// - Parameter environmentBehaviour: The ``PresentationEnvironmentBehaviour`` to use when presenting views. Defaults to `.useContext`.
    /// - Returns: Modified content that handles child anchor presentations.
    nonisolated func anchorPresentationContext(environmentBehaviour: PresentationEnvironmentBehaviour = .useContext) -> some View {
        modifier(AnchorPresentationContext2(environmentBehaviour: environmentBehaviour))
    }
    
    
    /// Uses this current view for the source anchor that the presentation will be auto anchored to in the first parent `anchorPresentationContext` available.
    /// Auto anchors are determined based on the location of the source view relative to its presentation context bounds.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func autoAnchorPresentation<P: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder presentation: @MainActor @escaping (AutoAnchorState) -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .auto,
            presentation: presentation
        ))
    }
    
    
    /// Uses this current view for the source alignment that the presentation will be aligned to in the first parent `alignedPresentationContext` available.
    ///
    /// - Note: With default anchor of source `center` and presentation `center` the presented views center will be aligned with the sources center. This will result in both views being centered on top of each other like defaut `ZStack` behaviour.
    /// Eg. If you want the presented views `center` to be aligned to the `topTrailing` corner of the source view, specify a source anchor of `topTrailing` and a presentation anchor of `center`.
    /// If you don't need the control of both the source and presentation alignment you can use the convenience anchor presentations:  `anchorBottomPresentation`, `anchorTopPresentation`,  `anchorLeadingPresentation`,  or `anchorTrailingPresentation` which will generate source and presentation anchors to give you alignment for the desired edge.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - sourceAnchor: The base anchor of the source view that the presentation will be relative to. Defaults to `.center`.
    ///   - presentationAnchor: The anchor of the presented view that will be relative to its source anchor.  Defaults to `.center`.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func anchorPresentation<P: View>(
        isPresented: Binding<Bool>,
        sourceAnchor: UnitPoint = .center,
        presentationAnchor: UnitPoint = .center,
        @ViewBuilder presentation: @MainActor @escaping () -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .manual(
                source: sourceAnchor,
                presentation: presentationAnchor
            ),
            presentation: { _ in presentation() }
        ))
    }
    
    
    
    /// A convenience anchor presentation for when the presented view will never overlap source view and will be anchored to the bottom edge.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - alignment: `HorizontalAlignment` of the views between source and presentation. Defaults to `.center`. Eg. If set to `leading`, the presented views `bottomLeading` anchor will be aligned to the `topLeading` anchor of the source view.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func anchorBottomPresentation<P: View>(
        isPresented: Binding<Bool>,
        alignment: HorizontalAlignment = .center,
        @ViewBuilder presentation: @MainActor @escaping () -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .manual(
                source: UnitPoint(Alignment(horizontal: alignment, vertical: .bottom)),
                presentation: UnitPoint(Alignment(horizontal: alignment, vertical: .top))
            ),
            presentation: { _ in presentation() }
        ))
    }
    
    
    /// A convenience anchor presentation for when the presented view will never overlap source view and will be anchored to the top edge.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - alignment: `HorizontalAlignment` of the views between source and presentation. Defaults to `.center`. Eg. If set to `leading`, the presented views `bottomLeading` anchor will be aligned to the `topLeading` anchor of the source view.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func anchorTopPresentation<P: View>(
        isPresented: Binding<Bool>,
        alignment: HorizontalAlignment = .center,
        @ViewBuilder presentation: @MainActor @escaping () -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .manual(
                source: UnitPoint(Alignment(horizontal: alignment, vertical: .top)),
                presentation: UnitPoint(Alignment(horizontal: alignment, vertical: .bottom))
            ),
            presentation: { _ in presentation() }
        ))
    }
    
    
    /// A convenience anchor presentation for when the presented view will never overlap source view and will be anchored to the leading edge.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - alignment: `VerticalAlignment` of the views between source and presentation. Defaults to `.center`. Eg. If set to `top`, the presented views `bottomLeading` anchor will be aligned to the `topLeading` anchor of the source view.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func anchorLeadingPresentation<P: View>(
        isPresented: Binding<Bool>,
        alignment: VerticalAlignment = .center,
        @ViewBuilder presentation: @MainActor @escaping () -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .manual(
                source: UnitPoint(Alignment(horizontal: .leading, vertical: alignment)),
                presentation: UnitPoint(Alignment(horizontal: .trailing, vertical: alignment))
            ),
            presentation: { _ in presentation() }
        ))
    }
    
    
    /// A convenience anchor presentation for when the presented view will never overlap the source view and will be anchored to the trailing edge.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - alignment: `VerticalAlignment` of the views between source and presentation. Defaults to `.center`. Eg. If set to `top`, the presented views `bottomLeading` anchor will be aligned to the `topLeading` anchor of the source view.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: Modified content that handles the anchor presentation.
    nonisolated func anchorTrailingPresentation<P: View>(
        isPresented: Binding<Bool>,
        alignment: VerticalAlignment = .center,
        @ViewBuilder presentation: @MainActor @escaping () -> P
    ) -> some View {
        modifier(AnchorPresenter(
            isPresented: isPresented,
            anchorMode: .manual(
                source: UnitPoint(Alignment(horizontal: .trailing, vertical: alignment)),
                presentation: UnitPoint(Alignment(horizontal: .leading, vertical: alignment))
            ),
            presentation: { _ in presentation() }
        ))
    }
    
}
