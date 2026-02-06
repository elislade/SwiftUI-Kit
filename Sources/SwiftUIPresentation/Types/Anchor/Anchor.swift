import SwiftUI
import SwiftUIKitCore


extension View {
    
    
    /// Defines an anchor presentation context for children to present in.
    /// - Returns: A modified view.
    nonisolated public func anchorPresentationContext() -> some View {
        modifier(AnchorPresentationContext())
    }
    
    
    /// Anchors the presented view to in the first parent `anchorPresentationContext` available.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - type: The type of anchor presentation to use.
    ///   - isLeader: `Bool` indicating if child anchored views follow the same type as this one. Defaults to `false`. Children that are also leaders will not follow and will instead become new leaders for their grandchildren.
    ///   - presentation: The view builder of the view to present.
    /// - Returns: A modified view.
    nonisolated public func anchorPresentation(
        isPresented: Binding<Bool>,
        type: PresentedAnchorType,
        isLeader: Bool = false,
        @ViewBuilder presentation: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(AnchorPresenter(
            value: isPresented,
            isLeader: isLeader,
            type: type,
            presentation: { _ in presentation() }
        ))
    }
    
    
    nonisolated public func anchorPresentation<Value:ValuePresentable>(
        value: Binding<Value>,
        type: PresentedAnchorType,
        isLeader: Bool = false,
        @ViewBuilder presentation: @MainActor @escaping (Value.Presented) -> some View
    ) -> some View {
        modifier(AnchorPresenter(
            value: value,
            isLeader: isLeader,
            type: type,
            presentation: presentation
        ))
    }
    
}
