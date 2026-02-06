import SwiftUI
import SwiftUIKitCore

struct ContextMenuPresenter<Source: View, Content: View, Presented: View>{
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    @State private var isPresented = false
    @State private var origin: CGPoint = .zero
    @State private var mouseLocation: SIMD2<Double> = .zero
    
    var presentedBinding: Binding<Bool>?
    let source: Source
    
    @ViewBuilder let presentedView: Presented
    @ViewBuilder let content: Content
    
    private var binding: Binding<Bool> {
        presentedBinding ?? $isPresented
    }
    
    private var ctxMenuBG: some View {
        Color.black.opacity(0.3)
    }
    
}


extension ContextMenuPresenter: View {
    
    #if os(macOS)
    
    var body: some View {
        source.onGeometryChangePolyfill(of: { $0.frame(in: .global).origin }){ old, new in
            origin = new
        }
        .disabled(isBeingPresentedOn)
        .background{
            Color.clear
                .frame(width: 1, height: 1)
                .anchorPresentation(isPresented: binding, type: .vertical(preferredAlignment: .leading)){ //_ in
                    MenuContainer{ content }
                        .presentationBackdrop{ Color.clear }
                        .submenuPresentationContext()
                        .transition((.scale(0.8) + .opacity).animation(.bouncy.speed(1.6)))
                }
                .position(mouseLocation)
        }
        .onMouseClick{ evt in
            self.mouseLocation = (evt.location ?? .zero) - [origin.x, origin.y]

            if evt.button == .right && evt.phase == .up {
                binding.wrappedValue = true
            } else {
                binding.wrappedValue = false
            }
        }
    }
    
    #else
    
    var body: some View {
        source
            .focusPresentation(
            isPresented: binding,
            focus: {
                Group {
                    if type(of: presentedView) == EmptyView.self {
                        source
                    } else {
                        presentedView
                    }
                }
                .presentationBackdrop { ctxMenuBG }
                .windowInteractionEffects([.parallax()])
                //.transition(.scale(0.8).animation(.bouncy.speed(1.6)))
            },
            accessory: {
                MenuContainer{ content }
                    .submenuPresentationContext()
                    .windowInteractionEffects([.scale(anchor: .center)])
                    .anchorLayoutPadding(10)
                    .transition(
                        .squish + .hitTestingDisabled
                    )
            }
        )
        .simultaneousLongPress {
            binding.wrappedValue = true
        }
    }
    
    #endif
    
}
