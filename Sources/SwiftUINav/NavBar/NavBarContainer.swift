import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavBarContainer<Content: View> : View {
    
    typealias Metadata = NavBarItemMetadata
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.reduceMotion) private var reduceMotion

    @State private var topInset: CGFloat = 0
    @State private var leadingInset: CGFloat = 0
    @State private var barIsHidden = false
    @State private var items: [PresentationValue<Metadata>] = []
    @State private var bgMaterial: [NavBarMaterialValue] = []
    
    private var scale: Double { verticalSizeClass == .compact ? 0.75 : 1.0 }
    
    private var padding: CGFloat {
        (16 - (8 * interactionGranularity)) * scale
    }
    
    private var minHeight: CGFloat {
        (80 - (28 * interactionGranularity)) * scale
    }
    
    private let content: () -> Content
    
    /// Initializes instance
    /// - Parameters:
    ///   - content: A view builder of the content that can set `NavBarContainer` items.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .presentationSafeAreaContext()
            .safeAreaInset(edge: .top, spacing: 0){
                if barIsHidden == false {
                    Bar(
                        isCompact: verticalSizeClass == .compact,
                        items: items
                    )
                    .padding(.horizontal, padding)
                    .padding(.vertical, 12)
                    .padding(.leading, leadingInset)
                    .padding(.top, -topInset)
                    .background {
                        if bgMaterial.isEmpty {
                            NavBarDefaultMaterial()
                                .windowDraggable()
                                .ignoresSafeArea()
                        } else {
                            bgMaterial.last?.view()
                                .windowDraggable()
                                .ignoresSafeArea()
                        }
                        
                        // compensate for iPadOS 26 TrafficLights / Window controls
                        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                            GeometryReader { proxy in
                                let width: CGFloat = proxy.containerCornerInsets.topLeading.width
                                Color.clear.onChangePolyfill(of: width, initial: true){
                                    leadingInset = width
                                }
                            }
                            
                            GeometryReader { proxy in
                                let height: CGFloat = proxy.containerCornerInsets.topLeading.height
                                Color.clear.onChangePolyfill(of: height, initial: true){
                                    topInset = height != 0 ? 20 : 0
                                }
                            }
                            .ignoresSafeArea()
                        }
                    }
                    .transition(
                        (.moveEdge(.top) + .offset([0, -120])).animation(.fastSpringInterpolating)
                    )
                }
            }
            .geometryGroupIfAvailable()
            .animation(.fastSpringInterpolating, value: barIsHidden)
            .presentationHandler{ items = $0.filter({ !$0.hidden }) }
            .preferenceChangeConsumer(NavBarMaterialKey.self){ bgMaterial = $0  }
            .preferenceChangeConsumer(NavBarHiddenKey.self){ barIsHidden = $0 }
    }
    
    
    struct Bar: View {
        
        @Environment(\.reduceMotion) private var reduceMotion
        
        let isCompact: Bool
        let items: [PresentationValue<Metadata>]
        
        private var titleTransition: AnyTransition {
            reduceMotion ? .opacity : .scale(0.9) + .opacity
        }
        
        private var actionsTransition: AnyTransition {
            reduceMotion ? .opacity : .scale(0.8, anchor: .top) + .opacity
        }
        
        private var minHeight: Double {
            let multiplier = isCompact ? 0.8 : 1.0
            #if canImport(AppKit)
            return 34 * multiplier
            #else
            return 44 * multiplier
            #endif
        }
        
        var body: some View {
            VStack(spacing: 10) {
                let itemGroupA = items.filter({
                    $0.placement == .leading || $0.placement == .title || $0.placement == .trailing
                })
                
                if !itemGroupA.isEmpty  {
                    HStack(spacing: 12) {
                        let leading = itemGroupA
                            .filter({ $0.placement == .leading })
                            .sorted(by: { $0.priority > $1.priority })
                        
                        ForEach(leading) { item in
                            item
                                .view
                                .transition(actionsTransition.animation(.bouncy))
                                .id(item.id)
                        }
                        .labelStyle(.iconOnly)
                        
                        if let title = itemGroupA
                            .filter({ $0.placement == .title })
                            .sorted(by: { $0.priority < $1.priority })
                            .last
                        {
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
 
                        let trailing = itemGroupA
                            .filter({ $0.placement == .trailing })
                            .sorted(by: { $0.priority < $1.priority })
                        
                        ForEach(trailing) { item in
                            item
                                .view
                                .transition(actionsTransition.animation(.bouncy))
                                .id(item.id)
                        }
                        .labelStyle(.iconOnly)
                    }
                    .overscrollGroup()
                    .frame(minHeight: minHeight)
                }
                
                let accessories = items.filter({ $0.placement == .accessory }).sorted(by: { $0.priority < $1.priority })
                ForEach(accessories) { item in
                    item
                        .view
                        .transition(actionsTransition.animation(.bouncy))
                }
            }
            .animation(.fastSpringInterpolating, value: items)
            .buttonStyle(.bar)
            .toggleStyle(.bar)
            .environment(\.isInNavBar, true)
            .accessibility(addTraits: .isHeader)
            .geometryGroupIfAvailable()
        }
    }
    
}
