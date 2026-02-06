import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

public struct Menu<Label: View, Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
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
            Button{ isOpen.toggle() } label: {
                label()
                    .opacity(isOpen ? 0.3 : 1)
                    .contentShape(RoundedRectangle(cornerRadius: 4).inset(by: -3))
                    .simultaneousLongPress { isOpen.toggle() }
            }
            .anchorPresentation(
                isPresented: $isOpen,
                type: .vertical(preferredAlignment: .leading)
            ){
                MenuContainer {
                    content()
                }
                .anchorLayoutPadding(16)
                .anchorLayoutAlignmentMode(.keepUntilPast(.center))
                .windowInteractionEffects([.squish])
                .presentationBackdrop(.changedPassthrough){ Color.clear }
                .submenuPresentationContext()
                .environment(\.colorScheme, colorScheme)
                .transition(.squish + .hitTestingDisabled)
            }
        }
    }
    
    
    struct InnerView<C: View>: View {
        
        let ns: Namespace.ID
        let id: UUID
        let content: C
        
        @State private var isSource = false
        
        var body: some View {
            MenuContainer {
                content
            }
            .anchorLayoutPadding(16)
            .anchorLayoutAlignmentMode(.keepUntilPast(.center))
            .windowInteractionEffects([.squish])
            .presentationBackdrop(.changedPassthrough){ Color.clear }
            .submenuPresentationContext()
            .matchedGeometryEffect(id: id, in: ns, isSource: true)
        }
    }
}



struct AnchorWrapper: ViewModifier {
    
    @Environment(\.anchorState) private var state
    @State private var anchorState: AnchorState = .init(.center, .topLeading)

    private var s: AnchorState { state ?? anchorState }
    
    func body(content: Content) -> some View {
        content
            .transition(
                .scale(scale: 0.8, anchor: .center).animation(.bouncy(extraBounce: 0.1).speed(1.6))
                + .opacity.animation(.easeInOut)
                + .hitTestingDisabled
            )
    }
    
}


extension AnyTransition {
    
    static var squish: AnyTransition {
        .scale(x: 0.2).animation(.bouncy(extraBounce: 0.2).speed(1.3))
        + .scale(y: 0.2).animation(.bouncy(extraBounce: 0.2).speed(1.3).delay(0.1))
        + .opacity.animation(.easeInOut)
        + .blur(radius: 10).animation(.linear)
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
