import SwiftUI
import SwiftUIKitCore


struct AnchorPresentationContext: ViewModifier {
    
    typealias Metadata = AnchorPresentationMetadata
    typealias Presentation = PresentationValue<Metadata>
    
    @Environment(\.presentationEnvironmentBehaviour) private var envBehaviour
    @Environment(\.layoutDirection) private var envLayoutDirection
    
    @State private var bgInteraction: PresentationBackgroundInteraction?
    @State private var bg: PresentationBackgroundKeyValue?
    @State private var presentedValue: Presentation?

    private var bgView: AnyView? { bg?.view() }
    
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
        presentedValue.dispose()
    }
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(presentedValue != nil)
            .accessibilityHidden(presentedValue != nil)
            .onPreferenceChange(PresentationKey<Metadata>.self) {
                _presentedValue.wrappedValue = $0.last
            }
            .overlay {
                GeometryReader{ proxy in
                    let proxyWidth = proxy.size.width
                    
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        if let presentedValue {
                            let dir = layoutDirection(for: presentedValue)
                            let sourceFrame = proxy[presentedValue.anchor]
                            let anchors = anchors(for: presentedValue, in: proxy)
                            let presEdge = AnchorHelper.presentationEdge(for: anchors.presentation, and: anchors.source)
                            
                            presentedValue.metadata
                                .view(.init(anchor: anchors.presentation, edge: presEdge ?? .bottom))
                                .environment(\._isBeingPresented, true)
                                .transition(
                                    (.scale(0, anchor: anchors.presentation) + .opacity)
                                        .animation(.bouncy.speed(1.6))
                                )
                                .environment(\.dismissPresentation, .init(id: presentedValue.id, closure: dismiss))
                                .onPreferenceChange(PresentationBackgroundKey.self){
                                    _bg.wrappedValue = $0.last
                                }
                                .onPreferenceChange(PresentationBackgroundInteractionKey.self){
                                    _bgInteraction.wrappedValue = $0.last
                                }
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
                .environment(\.layoutDirection, layoutDirection)
                .background {
                    if presentedValue != nil {
                        PresentationBackground(
                            bgView: bgView,
                            bgInteraction: bgInteraction,
                            dismiss: dismiss
                        )
                        .transitions(.opacity.animation(.smooth))
                    }
                }
            }
            .transformPreference(PresentationKey<Metadata>.self){
                // don't let presentations continue up the chain if caught by this context
                $0 = []
            }
        }
    
}
