import SwiftUI
import SwiftUIKitCore

struct ContextMenuPresenter<Source: View, Content: View, Presented: View>: View {
    
    var presentedBinding: Binding<Bool>?
    
    let source: Source
    @ViewBuilder let presentedView: Presented
    @ViewBuilder let content: Content
    
    @State private var isPresented = false
    @State private var origin: CGPoint = .zero
    @State private var mouseLocation: CGPoint = .zero
    
    private var binding: Binding<Bool> {
        presentedBinding ?? $isPresented
    }
    
    private var ctxMenuBG: some View {
        ZStack {
            VisualEffectView(blurRadius: 10)
            Color.black.opacity(0.3)
        }
        .simultaneousLongPress { isPresented = true }
    }
    
    
}


public extension View {
    
    
    func contextMenuPresentationContext() -> some View {
        focusPresentationContext()
    }
    
    
    /// - Parameters:
    ///   - isPresented: Programatically show or hide the context menu for this view. Default value is a constant binding if you don't need programatic access like in the pre-existing Apple `contextMenu` view modifer.
    ///   - items: A View Builder of the context menu items to present.
    /// - Returns: A `ContextMenuPresenter` view.
    func contextCustomMenu<Menu: View>(
        isPresented: Binding<Bool>? = nil,
        @ViewBuilder items: @escaping () -> Menu
    ) -> some View {
        ContextMenuPresenter(
            presentedBinding: isPresented,
            source: self,
            presentedView: { EmptyView() },
            content: items
        )
    }
    
    
    /// - Parameters:
    ///   - isPresented: Programatically show or hide the context menu for this view. Default value is a constant binding if you don't need programatic access like in the pre-existing Apple `contextMenu` view modifer.
    ///   - presented: A View Builder of the view that replaces the source view when presented.
    ///   - items: A View Builder of the context menu items to present.
    /// - Returns: A `ContextMenuPresenter` view.
    func contextCustomMenu<Menu: View, Presented: View>(
        isPresented: Binding<Bool>? = nil,
        @ViewBuilder presented: @escaping () -> Presented,
        @ViewBuilder items: @escaping () -> Menu
    ) -> some View {
        ContextMenuPresenter(
            presentedBinding: isPresented,
            source: self,
            presentedView: presented,
            content: items
        )
    }
    
    
}
