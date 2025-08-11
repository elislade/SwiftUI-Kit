import SwiftUI
import SwiftUIKitCore

public struct Menu<Label: View, Content: View>: View {
    
    @Environment(\.isInMenu) private var isInMenu
    @State private var id = UUID()
    @State private var isOpen = false
    @ViewBuilder private let label: @MainActor () -> Label
    @ViewBuilder private let content: @MainActor () -> Content
    
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
            Button{ isOpen = true } label: {
                label()
                    .opacity(isOpen ? 0.3 : 1)
                    .contentShape(Rectangle())
                    .simultaneousLongPress { isOpen = true }
            }
            .buttonStyle(.plain)
            //.presentationMatch(id)
            .anchorPresentation(isPresented: $isOpen){ state in
                MenuContainer {
                    content()
                }
                //.presentationMatch(id)
                .padding(.init(state.edge))
                .windowInteractionEffects([.scale(anchor: state.anchor)])
                .presentationBackdrop(.touchEndedDismiss){ Color.clear }
                .submenuPresentationContext()
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
