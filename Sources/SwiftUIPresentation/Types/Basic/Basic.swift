import SwiftUI

public extension View {
    
    
    /// Defines the presentation context for which children that use presentation will present to.
    nonisolated func basicPresentationContext() -> some View {
        modifier(BasicPresentationContext())
    }
    
    
    /// Presents a view in the first  parent `presentationContext` available.
    /// - Note: With this custom presentation behaviour you are responsible for setting the presented views size, transitions, and background.
    ///
    /// - Parameters:
    ///   - isPresented: A binded Bool to programatically present or dismiss presentation.
    ///   - alignment: Alignment that view will be placed to if smaller then the presentation context bounds.  Defaults to bottom.
    ///   - content: A View Builder of the content you want to present.
    ///
    /// - Note: If presented views size is not smaller in the given dimension for the alignment no difference will be noticed. Eg. If you set the alignment to leading but the presented view is not smaller then the contexts width then it will have no effect on the presentation location. Alignment will have no effect on the views transition. To control the presentation transition just use the SwiftUI `transition` modifier on the presented view.
    nonisolated func presentation<Content: View>(
        isPresented: Binding<Bool>,
        alignment: Alignment = .bottom,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) -> some View {
        modifier(BasicPresenter(
            isPresented: isPresented,
            alignment: alignment,
            presentation: content
        ))
    }
    
    nonisolated func presentation<Content: View, Value: Hashable>(
        value: Binding<Value?>,
        alignment: Alignment = .bottom,
        @ViewBuilder content: @MainActor @escaping (Value) -> Content
    ) -> some View {
        modifier(BasicPresenterOptional(
            value: value,
            alignment: alignment,
            presentation: content
        ))
    }
    
}
