import SwiftUI
import SwiftUIKitCore

extension View {
    
    
    /// Defines the context for which to present children `focusPresentations` in.
    /// - Returns: A view that sets the focus presentation context.
    nonisolated public func focusPresentationContext() -> some View {
        modifier(FocusPresentationContext())
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameter isPresented: A binding to the presentation for programatic presentation and dismissal.
    /// - Returns: A view that presents this view for focus presentation.
    public func focusPresentation(isPresented: Binding<Bool>) -> some View {
        modifier(FocusPresenter(
            value: isPresented,
            focusView: { _ in self }
        ))
    }
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    /// - Returns: A view that presents the focus view for presentation.
    nonisolated public func focusPresentation(
        isPresented: Binding<Bool>,
        @ViewBuilder focus: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(FocusPresenter(
            value: isPresented,
            focusView: { _ in focus() }
        ))
    }
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - value: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    /// - Returns: A view that presents the focus view for presentation.
    nonisolated public func focusPresentation<Value: ValuePresentable>(
        value: Binding<Value>,
        @ViewBuilder focus: @MainActor @escaping (Value.Presented) -> some View
    ) -> some View {
        modifier(FocusPresenter(
            value: value,
            focusView: focus
        ))
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - focus: A ViewBuilder for the focused view that will replace this current view when focusing
    ///   - accessory: A ViewBuilder that will show alongside the presented view with auto aligned behaviour.
    /// - Returns: A view that presents the focus view for presentation.
    nonisolated public func focusPresentation(
        isPresented: Binding<Bool>,
        @ViewBuilder focus: @MainActor @escaping () -> some View,
        @ViewBuilder accessory: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(FocusPresenter(
            value: isPresented,
            focusView: { _ in focus() },
            accessory: { AnyView(accessory()) }
        ))
    }
    
    
    /// Focuses this current view in the first parent focusPresentationContext available.
    /// - Parameters:
    ///   - isPresented: A binding to the presentation for programatic presentation and dismissal.
    ///   - accessory: A ViewBuilder that will show alongside the presented view with auto aligned behaviour.
    /// - Returns: A view that presents this view for focus presentation.
    public func focusPresentation(
        isPresented: Binding<Bool>,
        @ViewBuilder accessory: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(FocusPresenter(
            value: isPresented,
            focusView: { _ in self },
            accessory: { AnyView(accessory()) }
        ))
    }
    
}
