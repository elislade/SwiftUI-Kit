import SwiftUI

public extension View {
    
    
    /// Defines the context for which to present children `focusPresentations` in.
    /// - Returns: A view that sets the focus presentation context.
    nonisolated func focusPresentationContext() -> some View {
        modifier(FocusPresentationContext())
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameter isPresented: A binding to the presentation for programatic presentation and dismissal.
    /// - Returns: A view that presents this view for focus presentation.
    func focusPresentation(isPresented: Binding<Bool>) -> some View {
        return FocusPresenter(
            isPresented: isPresented,
            content: { self },
            focusView: { AnyView(self) }
        )
    }
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    /// - Returns: A view that presents the focus view for presentation.
    func focusPresentation<Focus: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder focus: @MainActor @escaping () -> Focus
    ) -> some View {
        FocusPresenter(
            isPresented: isPresented,
            content: { self },
            focusView: { AnyView(focus()) }
        )
    }
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - value: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    /// - Returns: A view that presents the focus view for presentation.
    func focusPresentation<Value: Hashable, Focus: View>(
        value: Binding<Value?>,
        @ViewBuilder focus: @MainActor @escaping (Value) -> Focus
    ) -> some View {
        FocusOptionalPresenter(
            value: value,
            content: { self },
            focusView: { AnyView(focus($0)) }
        )
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    ///   - accessory: A ViewBuilder that will show alongside the presented view with auto aligned behaviour.
    /// - Returns: A view that presents the focus view for presentation.
    func focusPresentation<Focus: View, Accessory: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder focus: @MainActor @escaping () -> Focus,
        @ViewBuilder accessory: @MainActor @escaping (AutoAnchorState) -> Accessory
    ) -> some View {
        FocusPresenter(
            isPresented: isPresented,
            content: { self },
            focusView: { AnyView(focus()) },
            accessory: { AnyView(accessory($0)) }
        )
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - accessory: A ViewBuilder that will show alongside the presented view with auto aligned behaviour.
    /// - Returns: A view that presents this view for focus presentation.
    func focusPresentation<Accessory: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder accessory: @MainActor @escaping (AutoAnchorState) -> Accessory
    ) -> some View {
        FocusPresenter(
            isPresented: isPresented,
            content: { self },
            focusView: { AnyView(self) },
            accessory: { AnyView(accessory($0)) }
        )
    }
    
}
