import SwiftUI

extension View {
    
    
    /// Defines the presentation context for which children that use presentation will present to.
    nonisolated public func basicPresentationContext() -> some View {
        modifier(BasicPresentationContext())
    }
    
    
    /// Presents a view in the first  parent `presentationContext` available.
    /// - Note: With this custom presentation behaviour you are responsible for setting the presented views size, transitions, and background.
    ///
    /// - Parameters:
    ///   - value: A binded value that reflects the presented views state.
    ///   - alignment: Alignment that view will be placed to if smaller then the presentation context bounds.  Defaults to bottom.
    ///   - content: A View Builder of the content you want to present.
    ///
    /// - Note: If presented views size is not smaller in the given dimension for the alignment no difference will be noticed. Eg. If you set the alignment to leading but the presented view is not smaller then the contexts width then it will have no effect on the presentation location. Alignment will have no effect on the views transition. To control the presentation transition just use the SwiftUI `transition` modifier on the presented view.
    nonisolated public func presentation<Value: ValuePresentable>(
        value: Binding<Value>,
        alignment: Alignment = .bottom,
        @ViewBuilder content: @MainActor @escaping (Value.Presented) -> some View
    ) -> some View {
        modifier(BasicPresenter(
            value: value,
            alignment: alignment,
            presentation: content
        ))
    }

    nonisolated public func presentation(
        isPresented: Binding<Bool>,
        alignment: Alignment = .bottom,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(BasicPresenter(
            value: isPresented,
            alignment: alignment,
            presentation: { _ in content() }
        ))
    }
    
}
