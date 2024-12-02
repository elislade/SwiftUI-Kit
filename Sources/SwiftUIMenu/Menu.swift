import SwiftUI
import SwiftUIKitCore

public struct Menu<Label: View, Content: View>: View {
    
    @Environment(\.menuBackground) private var menuBackground
    @Environment(\.isInMenu) private var isInMenu
    
    @State private var simulatedGesture: InteractionEvent?
    @State private var isOpen = false
    
    @ViewBuilder let label: Label
    @ViewBuilder let content: Content
    
    public init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label()
        self.content = content()
    }
    
    /// A
    /// - Parameters:
    ///   - content: A
    ///   - label: A
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label()
        self.content = content()
    }
    
    public var body: some View {
        if isInMenu {
            SubmenuPresenter(
                label: { label },
                content: { content }
            )
        } else {
            Button(action: { isOpen = true }){
                label
                    .opacity(isOpen ? 0.3 : 1)
                    .contentShape(Rectangle())
                    .simultaneousLongPress { isOpen = true }
            }
            .buttonStyle(.plain)
            .autoAnchorPresentation(isPresented: $isOpen){ state in
                MenuContainer {
                    content
                }
                .padding(.init(state.edge))
                .shadow(color: .black.opacity(0.1), radius: 30, y: 20)
                .windowInteractionEffects([.scale(anchor: state.anchor)])
                .presentationBackground(.touchChangeDismiss){ Color.clear }
                .modifier(SubmenuPresentationContext())
                .environment(\.menuBackground, menuBackground)
            }
            
        }
    }
    
}


public extension Menu where Label == Text {
    
    init(
        _ label: Text,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.content = content()
    }
    
    init(
        _ string: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(Text(string), content: content)
    }
    
}

extension CGFloat {
    static let menuLeadingSpacerSize: Self = 32
}
