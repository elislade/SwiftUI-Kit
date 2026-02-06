import SwiftUI
import SwiftUIKitCore


extension View {
    
    nonisolated public func contextMenuXContext() -> some View {
        focusPresentationContext()
    }
    
    
    /// - Parameter items: A View Builder of the context menu items to present.
    /// - Returns: A `ContextMenuPresenter` view.
    nonisolated public func contextMenuX(@ViewBuilder items: @escaping () -> some View) -> some View {
        ContextMenuPresenter(
            presentedBinding: nil,
            source: self,
            presentedView: { EmptyView() },
            content: items
        )
    }
    
    
    /// - Parameters:
    ///   - isPresented: Programatically show or hide the context menu.
    ///   - items: A View Builder of the context menu items to present.
    /// - Returns: A `ContextMenuPresenter` view.
    nonisolated public func contextMenuX(isPresented: Binding<Bool>, @ViewBuilder items: @escaping () -> some View) -> some View {
        ContextMenuPresenter(
            presentedBinding: isPresented,
            source: self,
            presentedView: { EmptyView() },
            content: items
        )
    }
    
    
    /// - Parameters:
    ///   - items: A View Builder of the context menu items to present.
    ///   - preview: A View Builder of the view that replaces the source view when presented.
    /// - Returns: A `ContextMenuPresenter` view.
    nonisolated public func contextMenuX(
        @ViewBuilder items: @escaping () -> some View,
        @ViewBuilder preview: @escaping () -> some View
    ) -> some View {
        ContextMenuPresenter(
            presentedBinding: nil,
            source: self,
            presentedView: preview,
            content: items
        )
    }
    
    
    /// - Parameters:
    ///   - isPresented: Programatically show or hide the context menu for this view.
    ///   - items: A View Builder of the context menu view to present.
    ///   - preview: A View Builder of the view that replaces the source view when presented.
    /// - Returns: A `ContextMenuPresenter` view.
    nonisolated public func contextMenuX(
        isPresented: Binding<Bool>,
        @ViewBuilder items: @escaping () -> some View,
        @ViewBuilder preview: @escaping () -> some View
    ) -> some View {
        ContextMenuPresenter(
            presentedBinding: isPresented,
            source: self,
            presentedView: preview,
            content: items
        )
    }
    
    
}
