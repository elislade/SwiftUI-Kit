import SwiftUI
import SwiftUIKitCore

struct ContextMenuPresenter<Source: View, Content: View, Presented: View>: View {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    var presentedBinding: Binding<Bool>?
    
    let source: Source
    @ViewBuilder let presentedView: Presented
    @ViewBuilder let content: Content
    
    @State private var isPresented = false
    @State private var origin: CGPoint = .zero
    @State private var mouseLocation: SIMD2<Double> = .zero
    
    private var binding: Binding<Bool> {
        presentedBinding ?? $isPresented
    }
    
    private var ctxMenuBG: some View {
        ZStack {
            VisualEffectView(blurRadius: 10)
            Color.black.opacity(0.3)
        }
    }
    
    var body: some View {
        source
#if os(macOS)
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin }){ old, new in
                origin = new
            }
            .disabled(isBeingPresentedOn)
            .background{
                Color.clear
                    .frame(width: 1, height: 1)
                    .autoAnchorOrthogonalToEdgePresentation(isPresented: binding, edge: .trailing){
                        MenuContainer{ content }
                            .presentationBackdrop{ Color.clear }
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
#else
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
                },
                accessory: { state in
                    MenuContainer{ content }
                        .shadow(radius: 10, y: 5)
                        .windowInteractionEffects([.scale(anchor: state.anchor)])
                        .padding(.init(state.edge))
                }
            )
            .simultaneousLongPress {
                binding.wrappedValue = true
            }
#endif
    }
    
    
}
