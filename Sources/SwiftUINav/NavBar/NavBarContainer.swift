import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


@MainActor public struct NavBarContainer<Content: View> : View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.reduceMotion) private var reduceMotion
    
    @State private var leadingSize: CGSize = .zero
    @State private var trailingSize: CGSize = .zero
    @State private var totalSize: CGSize = .zero
    
    private var titleWidth: CGFloat {
        let width = [leadingSize.width, trailingSize.width].sorted().last ?? 0
        let widthAndPad = width == 0 ? 0.0 : width + 12
        return totalSize.width - (widthAndPad * 2)
    }
    
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
    
    private var titleTransition: AnyTransition {
        reduceMotion ? .opacity : .merge(.scale(0.9), .opacity)
    }
    
    private var actionsTransition: AnyTransition {
        reduceMotion ? .opacity : .merge(.scale(0.8, anchor: .top), .opacity)
    }
    
    /// Initializes instance
    /// - Parameters:
    ///   - backAction: A `BackAction` that has a visible flag. Defaults to `.none` equivilant to a `BackAction` with an empty closure and visible set to false.
    ///   - content: A view builder of the content that can set `NavBarContainer` items.
    @MainActor public init(backAction: BackAction = .none, @ViewBuilder content: @escaping () -> Content) {
        self.backAction = backAction
        self.content = content
    }
    
    private func barView() -> some View {
        VStack(spacing: 10) {
            if !(items.isEmpty && !backAction.visible) {
                ZStack {
                    HStack(spacing: 0) {
                        HStack(spacing: 10) {
                            if backAction.visible {
                                Button(action: backAction.action) {
                                    Image(systemName: "arrow.left")
                                        .layoutDirectionMirror()
                                        .accessibility(label: Text("Go Back"))
                                }
                                .transitions(.move(edge: .leading), .opacity)
                            }
                            
                            items.filter({ $0.metadata.placement == .leading }).last?.view()
                                .transition(actionsTransition)
                        }
                        .onGeometryChangePolyfill(of: { $0.size }){ leadingSize = $0 }
                        
                        Spacer(minLength: 44)
                        
                        HStack(spacing: 10) {
                            items.filter({ $0.metadata.placement == .trailing }).last?.view()
                               .transition(actionsTransition)
                        }
                        .onGeometryChangePolyfill(of: { $0.size }){ trailingSize = $0 }
                    }
                    .onGeometryChangePolyfill(of: { $0.size }){ totalSize = $0 }
                    
                    items.filter({ $0.metadata.placement == .title }).last?.view()
                        .frame(maxWidth: titleWidth)
                        .transition(.merge(.scale, .opacity).animation(.bouncy))
                }
                #if canImport(AppKit)
                .frame(minHeight: 34)
                #else
                .frame(minHeight: 44)
                #endif
            }
            
            items.filter({ $0.metadata.placement == .accessory }).last?.view()
                .transition(actionsTransition)
        }
        .buttonStyle(.navBarStyle)
        .toggleStyle(.navBarStyle)
        .labelStyle(.titleIfFits)
        .padding(padding)
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .background {
            if bgMaterial.isEmpty {
                NavBarDefaultMaterial().ignoresSafeArea()
            } else {
                bgMaterial.last?.view().ignoresSafeArea()
            }
        }
        .accessibility(addTraits: .isHeader)
        .environment(\.isInNavBar, true)
        .animation(.fastSpringInterpolating, value: !backAction.visible)
        .windowDraggable()
        #if canImport(AppKit)
        .controlSize(.small)
        #endif
    }
    
    public var body: some View {
        content().safeAreaInset(edge: .top, spacing: 0){
            if barIsHidden == false {
                barView()
                    .transitions(.move(edge: .top), .offset(y: -120))
            }
        }
        .animation(.fastSpringInterpolating, value: barIsHidden)
        .onPreferenceChange(NavBarMaterialKey.self){ _bgMaterial.wrappedValue = $0 }
        .onPreferenceChange(PresentationKey.self){ _items.wrappedValue = $0 }
        .onPreferenceChange(NavBarHiddenKey.self){ _barIsHidden.wrappedValue = $0 }
    }
}


public struct BackAction {
    
    public var visible: Bool
    public let action: () -> Void
    
    public init(visible: Bool = true, action: @escaping () -> Void) {
        self.visible = visible
        self.action = action
    }
    
    public func callAsFunction() {
        action()
    }
    
    public static var none: BackAction {
        BackAction(visible: false, action: {})
    }
    
}
