import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavBarContainer<Content: View> : View {
    
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
    
    private let backAction: (@Sendable () -> Void)?
    private let content: () -> Content
    
    private var titleTransition: AnyTransition {
        reduceMotion ? .opacity : .merge(.scale(0.9), .opacity)
    }
    
    private var actionsTransition: AnyTransition {
        reduceMotion ? .opacity : .merge(.scale(0.8, anchor: .top), .opacity)
    }
    
    /// Initializes instance
    /// - Parameters:
    ///   - backAction: An optonal closure that when set will show a back button in leading position. Defaults to nil.
    ///   - content: A view builder of the content that can set `NavBarContainer` items.
    @MainActor public init(backAction: (@Sendable () -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.backAction = backAction
        self.content = content
    }
    
    private func barView() -> some View {
        VStack(spacing: 10) {
            if !(items.isEmpty && backAction == nil) {
                ZStack {
                    HStack(spacing: 0) {
                        HStack(spacing: 10) {
                            if let backAction {
                                Button(action: backAction) {
                                    Image(systemName: "arrow.left")
                                        .layoutDirectionMirror()
                                        .accessibility(label: Text("Go Back"))
                                }
                                .transitions(.move(edge: .leading), .opacity)
                            }
                            
                            items.filter({ $0.metadata.placement == .leading }).last?.view()
                                .transition(actionsTransition)
                        }
                        .boundsReader(readingToSize: $leadingSize)
                        
                        Spacer(minLength: 44)
                        
                        HStack(spacing: 10) {
                            items.filter({ $0.metadata.placement == .trailing }).last?.view()
                               .transition(actionsTransition)
                        }
                        .boundsReader(readingToSize: $trailingSize)
                    }
                    .boundsReader(readingToSize: $totalSize)
                    
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
                bgMaterial.last?.view.ignoresSafeArea()
            }
        }
        .accessibility(addTraits: .isHeader)
        .environment(\.isInNavBar, true)
        .animation(.fastSpringInterpolating, value: backAction == nil)
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
        .onPreferenceChange(NavBarMaterialKey.self){ bgMaterial = $0 }
        .onPreferenceChange(PresentationKey.self){ items = $0 }
        .onPreferenceChange(NavBarHiddenKey.self){ barIsHidden = $0 }
    }
}
