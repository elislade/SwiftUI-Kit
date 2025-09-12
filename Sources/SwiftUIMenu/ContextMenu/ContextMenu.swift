import SwiftUI
import SwiftUIKitCore


public extension View {
    
    nonisolated func customContextMenuContext() -> some View {
        focusPresentationContext()
    }
    
    
    /// - Parameter items: A View Builder of the context menu items to present.
    /// - Returns: A `ContextMenuPresenter` view.
    nonisolated func customContextMenu<Menu: View>(@ViewBuilder items: @escaping () -> Menu) -> some View {
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
    nonisolated func customContextMenu<Menu: View>(isPresented: Binding<Bool>, @ViewBuilder items: @escaping () -> Menu) -> some View {
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
    nonisolated func customContextMenu<Menu: View, Preview: View>(
        @ViewBuilder items: @escaping () -> Menu,
        @ViewBuilder preview: @escaping () -> Preview
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
    nonisolated func customContextMenu<Menu: View, Preview: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder items: @escaping () -> Menu,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        ContextMenuPresenter(
            presentedBinding: isPresented,
            source: self,
            presentedView: preview,
            content: items
        )
    }
    
    
}
