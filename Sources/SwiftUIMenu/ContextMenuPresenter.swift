import SwiftUI
import SwiftUIKitCore

struct ContextMenuPresenter<Source: View, Content: View, Presented: View>: View {
    
    @Binding var presentedBinding: Bool
    
    let source: Source
    @ViewBuilder let presentedView: Presented
    @ViewBuilder let content: Content
    
    @State private var isPresented = false
    @State private var simulatedGesture: InteractionEvent?
    
    private var ctxMenuBG: some View {
        ZStack {
            VisualEffectView(blurRadius: 10)
            Color.black.opacity(0.3)
        }
    }
    
    var body: some View {
        source.focusPresentation(
            isPresented: $isPresented,
            focus: {
                Group {
                    if type(of: presentedView) == EmptyView.self {
                        source
                    } else {
                        presentedView
                    }
                }
                .presentationBackground { ctxMenuBG }
                .coordinatedTouchesEffects([.parallax()])
            },
            accessory: { state in
                MenuContainer{ content }
                    .shadow(radius: 10, y: 5)
                    .coordinatedTouchesEffects([.scale(anchor: state.anchor)])
                    .padding(.init(state.edge))
            }
        )
        .onChangePolyfill(of: presentedBinding, initial: true){
            guard presentedBinding != isPresented else { return }
            isPresented = presentedBinding
                
        }
        .onChange(of: isPresented){
            guard $0 != presentedBinding else { return }
            presentedBinding = $0
        }
        .overlay {
            #if canImport(UIKit)
            MenuGestureRepresentation(
                onChanged: { g in
                    isPresented = true
                },
                onEnded: { _ in
                    simulatedGesture = nil
                }
            )
            #endif
        }
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
        isPresented: Binding<Bool> = .constant(false),
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
        isPresented: Binding<Bool> = .constant(false),
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
