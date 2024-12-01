import SwiftUI

public extension View {
    
    
    /// Defines the presentation context for which children that use presentation will present to.
    nonisolated func presentationContext() -> some View {
        modifier(BasicPresentationContext())
    }
    
    
    /// Presents a view in the first  parent `presentationContext` available.
    /// - Note: With this custom presentation behaviour you are responsible for setting the presented views size, transitions, and background.
    ///
    /// - Parameters:
    ///   - isPresented: A binded Bool to programatically present or dismiss presentation.
    ///   - alignment: Alignment that view will be placed to if smaller then the presentation context bounds. If presented views size is not smaller in the given dimension for the alignment no difference will be noticed. Eg. If you set the alignment to leading but the presented view is not smaller then the contexts width then it will have no effect on the presentation location. Alignment will have no effect on the views transition. To control the presentation transition just use the SwiftUI `transition` modifier on the presented view. Defaults to bottom alignment to replicate a modal placement at bottom of screen.
    ///   - presentation: A View Builder of the view you want to present.
    nonisolated func presentation<Content: View>(
        isPresented: Binding<Bool>,
        alignment: Alignment = .bottom,
        @ViewBuilder presentation: @MainActor @escaping () -> Content
    ) -> some View {
        modifier(BasicPresenter(
            isPresented: isPresented,
            alignment: alignment,
            presentation: presentation
        ))
    }
    
    
}
