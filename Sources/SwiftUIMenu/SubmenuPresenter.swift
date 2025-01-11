import SwiftUI
import SwiftUIPresentation

struct SubmenuPresenter<Label: View, Content: View>: View {
    
    @State private var id = UUID()
    @State private var isPresented = false
    
    @ViewBuilder let label: @MainActor() -> Label
    @ViewBuilder let content: @MainActor() -> Content
    
    private func present() {
        isPresented = true
    }
    
    var body: some View {
        Header(isStandalone: true, action: present, label: label)
            .anchorPreference(key: SubmenuPresentationKey.self, value: .bounds){ anchor in
                isPresented ? [
                    .init(
                        id: id,
                        labelAnchor: anchor,
                        menu: {
                            AnyView(Submenu(
                                label: label,
                                content: content
                            ))
                        },
                        dismiss: {
                            DispatchQueue.main.async {
                                isPresented = false
                            }
                        }
                    )
                ] : []
            }
    }
    
    
}


struct Header<L: View> : View {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.isBeingPresented) private var isPresented
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    @Environment(\.dismissPresentation) private var dismiss
    
    @State private var leadingWidth: CGFloat = .menuLeadingSpacerSize
    
    var isStandalone = false
    var action: @MainActor () -> Void = {}
    @ViewBuilder let label: @MainActor () -> L
    
    private var isExpanded: Bool { !isStandalone && isPresented }
    
    private var layoutNormalizeFactor: Double {
        layoutDirection == .leftToRight ? 1 : -1
    }
    
    private func closure() {
        if isExpanded {
            dismiss()
        } else {
            action()
        }
    }
    
    var body: some View {
        Button(action: closure){
            label()
                .frame(maxWidth: .infinity, alignment: .leading)
                .equalInsetItem(.leading, leadingWidth)
                .overlay(alignment: .leading){
                    Image(systemName: "chevron.right")
                        .rotationEffect(isExpanded ? .degrees(90 * layoutNormalizeFactor) : .zero)
                        //.frame(width: 12)
                        .layoutDirectionMirror()
                        .padding(.horizontal, 12)
                        .onGeometryChangePolyfill(of: { $0.size.width }){ leadingWidth = $0 }
                        
                }
        }
        .buttonStyle(MenuButtonStyle(dismissOnAction: false))
        .animation(.smooth, value: isPresentedOn)
        .menuActionDwellDuration(0.4)
    }
    
}


struct Submenu<C: View, L: View> : View {
    
    @Environment(\.isBeingPresented) private var isPresented
    
    @ViewBuilder let label: @MainActor () -> L
    @ViewBuilder let content: @MainActor () -> C
    
    var body: some View {
        MenuContainer {
            VStack(spacing: 0) {
                Header(label: label)
                
                if isPresented {
                    Divider()
                    content()
                }
            }
        }
        .animation(.bouncy, value: isPresented)
    }
    
}
