import SwiftUI
import SwiftUIKitCore


struct AnchorPresentationContext: ViewModifier {
    
    typealias Metadata = AnchorPresentationMetadata
    typealias Presentation = PresentationValue<Metadata>
    
    @Environment(\.presentationEnvironmentBehaviour) private var envBehaviour
    @Environment(\.layoutDirection) private var envLayoutDirection
    
    @State private var willDismiss: [PresentationWillDismissAction] = []
    @State private var backdropPreference: BackdropPreference?
    @State private var presentedValue: Presentation?

    nonisolated init() { }
    
    private var layoutDirection: LayoutDirection {
        guard let presentedValue else { return envLayoutDirection }
        return layoutDirection(for: presentedValue)
    }
    
    private func layoutDirection(for presentation: Presentation) -> LayoutDirection {
        switch envBehaviour {
        case .usePresentation: presentation.layoutDirection
        case .useContext: envLayoutDirection
        }
    }
    
    private func anchors(for value: Presentation, in proxy: GeometryProxy) -> (source: UnitPoint, presentation: UnitPoint) {
        let rect = proxy[value.anchor]
        let alignment = value.anchorAlignment
        let dir = layoutDirection(for: value)
        
        let source = UnitPoint(
            x: alignment.source.x.fraction ?? AnchorHelper.sourceAnchorX(
                for: rect,
                in: proxy.size,
                shouldInvert: dir == .rightToLeft
            ),
            y: alignment.source.y.fraction ?? AnchorHelper.sourceAnchorY(for: rect, in: proxy.size)
        )
        
        let presentation = UnitPoint(
            x: alignment.presentation.x.fraction ?? AnchorHelper.presentationAnchorX(
                for: rect,
                in: proxy.size,
                shouldInvert: dir == .rightToLeft
            ),
            y: alignment.presentation.y.fraction ?? AnchorHelper.presentationAnchorY(for: rect, in: proxy.size)
        )
       
        return (source, presentation)
    }
    
    private func dismiss() {
        guard let presentedValue else { return }
        for action in willDismiss {
            action()
        }
        presentedValue.dispose()
    }
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(presentedValue != nil)
            .disableOnPresentationWillDismiss(presentedValue != nil)
            .accessibilityHidden(presentedValue != nil)
            .onPreferenceChange(PresentationKey<Metadata>.self) {
                presentedValue = $0.last
            }
            .resetPreference(PresentationKey<Metadata>.self)
            .overlay {
                GeometryReader{ proxy in
                    let proxyWidth = proxy.size.width
                    
                    ZStack(alignment: .topLeading) {
                        Color.clear.zIndex(1)
                        
                        if let presentedValue {
                            let dir = layoutDirection(for: presentedValue)
                            let sourceFrame = proxy[presentedValue.anchor]
                            let anchors = anchors(for: presentedValue, in: proxy)
                            let presEdge = AnchorHelper.presentationEdge(for: anchors.presentation, and: anchors.source)
                            
                            presentedValue.metadata
                                .view(.init(anchor: anchors.presentation, edge: presEdge ?? .bottom))
                                .zIndex(2)
                                .environment(\._isBeingPresented, true)
                                .transition(
                                    (.scale(0, anchor: anchors.presentation) + .opacity)
                                        .animation(.bouncy.speed(1.6))
                                )
                                .environment(\.dismissPresentation, .init(id: presentedValue.id, closure: dismiss))
                                .onBackdropPreferenceChange{ backdropPreference = $0 }
                                .alignmentGuide(.leading){ dimension in
                                    let selfOffset = dimension.width * anchors.presentation.x
                                    
                                    let range = dir == .leftToRight ? [sourceFrame.minX, sourceFrame.maxX] : [sourceFrame.maxX, sourceFrame.minX]
                                    let sourceStart = ((range[1] - range[0]) * anchors.source.x) + range[0]
                                    
                                    if dir == .rightToLeft {
                                        return -(proxyWidth - (sourceStart + selfOffset))
                                    } else {
                                        return -(sourceStart - selfOffset)
                                    }
                                }
                                .alignmentGuide(.top){ dimension in
                                    let selfOffset = dimension.height * anchors.presentation.y
                                    
                                    let range = [sourceFrame.minY, sourceFrame.maxY]
                                    let sourceStart = ((range[1] - range[0]) * anchors.source.y) + range[0]
                                    
                                    return -(sourceStart - selfOffset)
                                }
                            }
                    }
                }
                .animation(.bouncy, value:  presentedValue)
                .environment(\.layoutDirection, layoutDirection)
                .background {
                    if presentedValue != nil {
                        BackdropView(preference: backdropPreference, dismiss: dismiss)
                        .transition((.opacity + .noHitTesting).animation(.smooth))
                    }
                }
            }
            .resetPreference(PresentationKey<Metadata>.self)
        }
    
}
