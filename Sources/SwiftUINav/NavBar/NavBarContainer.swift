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
    
    private let content: () -> Content
    
    /// Initializes instance
    /// - Parameters:
    ///   - content: A view builder of the content that can set `NavBarContainer` items.
    @MainActor public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .safeAreaInset(edge: .top, spacing: 0){
                if barIsHidden == false {
                    Bar(items: items)
                        .padding(padding)
                        .frame(maxWidth: .infinity, minHeight: minHeight)
                        .clipped()
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
            .geometryGroupPolyfill()
            .animation(.fastSpringInterpolating, value: barIsHidden)
            .onPreferenceChange(NavBarMaterialKey.self){ bgMaterial = $0 }
            .onPreferenceChange(PresentationKey.self){ items = $0 }
            .onPreferenceChange(NavBarHiddenKey.self){ barIsHidden = $0 }
            .resetPreference(NavBarMaterialKey.self)
            .resetPreference(NavBarHiddenKey.self)
            .resetPreference(PresentationKey<NavBarItemMetadata>.self)
    }
    
    
    struct Bar: View {
        
        @Environment(\.reduceMotion) private var reduceMotion
        
        let items: [PresentationValue<NavBarItemMetadata>]
        
        private var titleTransition: AnyTransition {
            reduceMotion ? .opacity : .scale(0.9) + .opacity
        }
        
        private var actionsTransition: AnyTransition {
            reduceMotion ? .opacity : .scale(0.8, anchor: .top) + .opacity
        }
        
        var body: some View {
            VStack(spacing: 10) {
                if !items.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(items.filter({ $0.metadata.placement == .leading }), id: \.id) { item in
                            item
                                .view
                                .transition(actionsTransition.animation(.bouncy))
                                .id(item.id)
                        }
                        
                        if let title = items.filter({ $0.metadata.placement == .title }).last {
                            title
                                .view
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(
                                    (.scale(0.8, anchor: .leading) + .opacity).animation(.bouncy)
                                )
                                .id(title.id)
                        } else {
                            Spacer(minLength: 0)
                        }
 
                        ForEach(items.filter({ $0.metadata.placement == .trailing }), id: \.id) { item in
                            item
                                .view
                                .transition(actionsTransition.animation(.bouncy))
                                .id(item.id)
                        }
                    }
                    .overscrollGroup()
                    #if canImport(AppKit)
                    .frame(minHeight: 34)
                    #else
                    .frame(minHeight: 44)
                    #endif
                }
                
                ForEach(items.filter({ $0.metadata.placement == .accessory }), id: \.id) { item in
                    item
                        .view
                        .transition(actionsTransition)
                }
            }
            .animation(.fastSpringInterpolating, value: items)
            .buttonStyle(.bar)
            .toggleStyle(.bar)
            .labelStyle(.viewThatFits(preferring: \.title))
            .environment(\.isInNavBar, true)
            .accessibility(addTraits: .isHeader)
            .geometryGroupPolyfill()
        }
    }
    
}
