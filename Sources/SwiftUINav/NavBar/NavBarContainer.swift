import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


@MainActor public struct NavBarContainer<Content: View> : View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.reduceMotion) private var reduceMotion

    @State private var barIsHidden = false
    @State private var items: [PresentationValue<NavBarItemMetadata>] = []
    @State private var bgMaterial: [NavBarMaterialValue] = []
    
    private var padding: CGFloat {
        16 - (8 * interactionGranularity)
    }
    
    private var minHeight: CGFloat {
        80 - (28 * interactionGranularity)
    }
    
    private let backAction: BackAction
    private let content: () -> Content
    
    /// Initializes instance
    /// - Parameters:
    ///   - backAction: A `BackAction` that has a visible flag. Defaults to `.none` equivilant to a `BackAction` with an empty closure and visible set to false.
    ///   - content: A view builder of the content that can set `NavBarContainer` items.
    @MainActor public init(backAction: BackAction = .none, @ViewBuilder content: @escaping () -> Content) {
        self.backAction = backAction
        self.content = content
    }
    
    public var body: some View {
        content()
            .safeAreaInset(edge: .top, spacing: 0){
                if barIsHidden == false {
                    Bar(backAction: backAction, items: items)
                        .padding(padding)
                        .frame(maxWidth: .infinity, minHeight: minHeight)
                        .paddingAddingSafeArea(.horizontal)
                        .background {
                            if bgMaterial.isEmpty {
                                NavBarDefaultMaterial().ignoresSafeArea()
                            } else {
                                bgMaterial.last?.view().ignoresSafeArea()
                            }
                        }
                        .windowDraggable()
                        .transitions(.move(edge: .top), .offset(y: -120))
                }
            }
            .animation(.fastSpringInterpolating, value: barIsHidden)
            .onPreferenceChange(NavBarMaterialKey.self){ _bgMaterial.wrappedValue = $0 }
            .onPreferenceChange(PresentationKey.self){ _items.wrappedValue = $0 }
            .onPreferenceChange(NavBarHiddenKey.self){ _barIsHidden.wrappedValue = $0 }
            .transformPreference(NavBarMaterialKey.self){ $0 = NavBarMaterialKey.defaultValue }
            .transformPreference(PresentationKey<NavBarItemMetadata>.self){ $0 = [] }
            .transformPreference(NavBarHiddenKey.self){ $0 = NavBarHiddenKey.defaultValue }
    }
    
    
    struct Bar: View {
        
        @Environment(\.reduceMotion) private var reduceMotion
        @State private var leadingWidth: CGFloat = .zero
        @State private var trailingWidth: CGFloat = .zero
        
        let backAction: BackAction
        let items: [PresentationValue<NavBarItemMetadata>]
        
        private var titleTransition: AnyTransition {
            reduceMotion ? .opacity : .merge(.scale(0.9), .opacity)
        }
        
        private var actionsTransition: AnyTransition {
            reduceMotion ? .opacity : .scale(0.8, anchor: .top) + .opacity
        }
        
        var body: some View {
            VStack(spacing: 10) {
                if !(items.isEmpty && !backAction.visible) {
                    ZStack {
                        HStack(spacing: 0) {
                            HStack(spacing: 10) {
                                if backAction.visible {
                                    Button(action: backAction.action) {
                                        Label { Text("Go Back") } icon: {
                                            Image(systemName: "arrow.left")
                                                .layoutDirectionMirror()
                                        }
                                    }
                                    .keyboardShortcut(SwiftUIKitCore.KeyEquivalent.escape, modifiers: [])
                                    .labelStyle(.iconOnly)
                                    .transitions(.move(edge: .leading), .opacity)
                                }
                                
                                if let leading = items.filter({ $0.metadata.placement == .leading }).last {
                                    leading
                                        .view()
                                        .transition(actionsTransition.animation(.bouncy))
                                        .id(leading.id)
                                }
                            }
                            .onGeometryChangePolyfill(of: { $0.size.width.rounded() }){ leadingWidth = $0 }
                            
                            Spacer(minLength: 44)
                            
                            HStack(spacing: 10) {
                                if let trailing = items.filter({ $0.metadata.placement == .trailing }).last {
                                    trailing
                                        .view()
                                        .transition(actionsTransition.animation(.bouncy))
                                        .id(trailing.id)
                                }
                            }
                            .onGeometryChangePolyfill(of: { $0.size.width.rounded() }){ trailingWidth = $0 }
                        }
                        
                        HStack(spacing: 5) {
                            Color.clear
                                .frame(width: max(leadingWidth, trailingWidth), height: 1)
                            
                            if let title = items.filter({ $0.metadata.placement == .title }).last {
                                title
                                    .view()
                                    .frame(maxWidth: .infinity)
                                    .transition(
                                        (.scale(0.4) + .opacity).animation(.bouncy)
                                    )
                                    .id(title.id)
                            }
                            
                            Color.clear
                                .frame(width: max(leadingWidth, trailingWidth), height: 1)
                        }
                    }
                    #if canImport(AppKit)
                    .frame(minHeight: 34)
                    #else
                    .frame(minHeight: 44)
                    #endif
                }
                
                items.filter({ $0.metadata.placement == .accessory }).last?
                    .view()
                    .transition(actionsTransition)
            }
            .animation(.fastSpringInterpolating, value: !backAction.visible)
            .buttonStyle(.navBarStyle)
            .toggleStyle(.navBarStyle)
            .labelStyle(.titleIfFits)
            .environment(\.isInNavBar, true)
            .accessibility(addTraits: .isHeader)
            .geometryGroupPolyfill()
        }
    }
    
}


public struct BackAction: Sendable {
    
    public var visible: Bool
    public var action: @MainActor () -> Void
    
    public init(visible: Bool = true, action: @escaping @MainActor () -> Void) {
        self.visible = visible
        self.action = action
    }
    
    @MainActor public func callAsFunction() {
        action()
    }
    
    public static var none: BackAction {
        BackAction(visible: false, action: {})
    }
    
}
