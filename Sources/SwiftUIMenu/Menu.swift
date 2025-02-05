import SwiftUI
import SwiftUIKitCore

public struct Menu<Label: View, Content: View>: View {
    
    @Environment(\.menuBackground) private var menuBackground
    @Environment(\.isInMenu) private var isInMenu
    
    @State private var isOpen = false
    
    @ViewBuilder let label: @MainActor () -> Label
    @ViewBuilder let content: @MainActor () -> Content
    
    public init(
        @ViewBuilder label: @MainActor @escaping () -> Label,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) {
        self.label = label
        self.content = content
    }
    

    public init(
        @ViewBuilder content: @MainActor @escaping () -> Content,
        @ViewBuilder label: @MainActor @escaping () -> Label
    ) {
        self.label = label
        self.content = content
    }
    
    public var body: some View {
        if isInMenu {
            SubmenuPresenter(
                label: { label() },
                content: { content() }
            )
        } else {
            Button(action: { isOpen = true }){
                label()
                    .opacity(isOpen ? 0.3 : 1)
                    .contentShape(Rectangle())
                    .simultaneousLongPress { isOpen = true }
            }
            .buttonStyle(.plain)
            .autoAnchorPresentation(isPresented: $isOpen){ state in
                MenuContainer {
                    content()
                }
                .padding(.init(state.edge))
                .shadow(color: .black.opacity(0.1), radius: 30, y: 20)
                .windowInteractionEffects([.scale(anchor: state.anchor)])
                .presentationBackground(.touchEndedDismiss){ Color.clear }
                .modifier(SubmenuPresentationContext())
                .environment(\.menuBackground, menuBackground)
            }
            .accessibilityRepresentation {
                content()
            }
        }
    }
    
}


public extension Menu where Label == Text {
    
    init(
        _ label: Text,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) {
        self.label = { label }
        self.content = content
    }
    
    init(
        _ string: String,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) {
        self.init(Text(string), content: content)
    }
    
}

extension CGFloat {
    static let menuLeadingSpacerSize: Self = 32
}
