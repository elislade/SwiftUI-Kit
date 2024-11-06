import SwiftUI
import SwiftUIKitCore

struct AnchorPresentationContext: ViewModifier {
    
    typealias Metadata = AnchorPresentationMetadata
    typealias Presentation = PresentationValue<Metadata>
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var bgInteraction: PresentationBackgroundInteraction?
    @State private var bgView: AnyView?
    
    @State private var presentedValue: Presentation?
    @State private var visuallyPresented = false
    @State private var showBG = false
    
    var environmentBehaviour: PresentationEnvironmentBehaviour = .useContext
    
    private func layoutDirection(for presentation: Presentation) -> LayoutDirection {
        switch environmentBehaviour {
        case .usePresentation: presentation.layoutDirection
        case .useContext: layoutDirection
        }
    }
    
    private func sourceAnchor(for value: Presentation, in proxy: GeometryProxy) -> UnitPoint {
        let dir = layoutDirection(for: value)
        switch value.anchorMode {
        case .auto:
            let a = AnchorHelper.sourceAnchor(for: proxy[value.anchor], in: proxy.size)
            return dir == .rightToLeft ? a.invert(.horizontal) : a
        case .manual(let source, _ ): return source
        }
    }
    
    private func presentationAnchor(for value: Presentation, in proxy: GeometryProxy) -> UnitPoint {
        let dir = layoutDirection(for: value)
        switch value.metadata.anchorMode {
        case .auto:
            let a = AnchorHelper.presentationAnchor(for: proxy[value.anchor], in: proxy.size)
            return dir == .rightToLeft ? a.invert(.horizontal) : a
        case .manual(_, let presentation): return presentation
        }
    }
    
    private func dismiss() {
        guard let presentedValue else { return }

        visuallyPresented = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            presentedValue.dispose()
            self.presentedValue = nil
        }
    }
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(visuallyPresented)
            .accessibilityHidden(presentedValue != nil)
            .onPreferenceChange(PresentationKey<Metadata>.self) { presentedValue = $0.last }
            .onChangePolyfill(of: presentedValue){ old, new in
                if old == nil && new != nil {
                    // presenting
                    visuallyPresented = true
                } else if old != nil && new == nil {
                    // dismissing
                    visuallyPresented = false
                } else if old?.id != new?.id {
                    // swapping
                    visuallyPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                        visuallyPresented = true
                    }
                }
            }
           .overlay {
                Color.clear
                
                if let presentedValue = presentedValue {
                    let dir = layoutDirection(for: presentedValue)
                    
                GeometryReader{ proxy in
                    let proxyWidth = proxy.size.width
                    let sourceFrame = proxy[presentedValue.anchor]
                    let presAnchor = presentationAnchor(for: presentedValue, in: proxy)
                    let sourceAnchor = sourceAnchor(for: presentedValue, in: proxy)
                    //let presAlignment = Alignment(presAnchor)
                    //let sourceAlignment = Alignment(sourceAnchor)
                    
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        ZStack {
                            if visuallyPresented {
                                presentedValue.metadata.view(.init(anchor: presAnchor, edge: .bottom))
                                    .environment(\._isBeingPresented, true)
//                                    .padding(.trailing, sourceAlignment.horizontal == .leading && presAlignment.horizontal == .trailing ? 14 : 0)
//                                    .padding(.leading, sourceAlignment.horizontal == .trailing && presAlignment.horizontal == .leading ? 14 : 0)
//                                    .padding(.top, sourceAlignment.vertical == .bottom && presAlignment.vertical == .top ? 14 : 0)
//                                    .padding(.bottom, sourceAlignment.vertical == .top && presAlignment.vertical == .bottom ? 14 : 0)
                                    .transition(
                                        .merge(.scale(0, anchor: presAnchor), .opacity)
                                        .animation(.bouncy)
                                    )
                                    .environment(\.dismissPresentation, .init(id: presentedValue.id, closure: dismiss))
                                    .onPreferenceChange(PresentationBackgroundKey.self){ bgView = $0.last?.view }
                                    .onPreferenceChange(PresentationBackgroundInteractionKey.self){ bgInteraction = $0.last }
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){ showBG = true }
                                    }
                                    .onDisappear {
                                        showBG = false
                                    }
                            }
                        }
                        .alignmentGuide(.leading){ dimension in
                            let selfOffset = dimension.width * presAnchor.x
         
                            let range = dir == .leftToRight ? [sourceFrame.minX, sourceFrame.maxX] : [sourceFrame.maxX, sourceFrame.minX]
                            let sourceStart = ((range[1] - range[0]) * sourceAnchor.x) + range[0]
                            
                            if dir == .rightToLeft {
                                return -(proxyWidth - (sourceStart + selfOffset))
                            } else {
                                return -(sourceStart - selfOffset)
                            }
                        }
                        .alignmentGuide(.top){ dimension in
                            let selfOffset = dimension.height * presAnchor.y
  
                            let range = [sourceFrame.minY, sourceFrame.maxY]
                            let sourceStart = ((range[1] - range[0]) * sourceAnchor.y) + range[0]
    
                            return -(sourceStart - selfOffset)
                        }
                    }
                }
                .environment(\.layoutDirection, dir)
                .background {
                    if showBG {
                        PresentationBackground(
                            bgView: bgView,
                            bgInteraction: bgInteraction,
                            dismiss: dismiss
                        )
                        .transitions(.opacity.animation(.smooth))
                        .opacity(visuallyPresented ? 1 : 0)
                    }
                }
            }
        }
        .transformPreference(PresentationKey<Metadata>.self){
            // don't let presentations continue up the chain if caught by this context
            $0 = []
        }
    }
    
}


struct AnchorPresentationContext2: ViewModifier {
    
    typealias Metadata = AnchorPresentationMetadata
    typealias Presentation = PresentationValue<Metadata>
    
    @Environment(\.layoutDirection) private var envLayoutDirection
    
    @State private var bgInteraction: PresentationBackgroundInteraction?
    @State private var bgView: AnyView?
    @State private var presentedValue: Presentation?
    
    var environmentBehaviour: PresentationEnvironmentBehaviour = .useContext
    
    private var layoutDirection: LayoutDirection {
        guard let presentedValue else { return envLayoutDirection }
        return layoutDirection(for: presentedValue)
    }
    
    private func layoutDirection(for presentation: Presentation) -> LayoutDirection {
        switch environmentBehaviour {
        case .usePresentation: presentation.layoutDirection
        case .useContext: envLayoutDirection
        }
    }
    
    private func sourceAnchor(for value: Presentation, in proxy: GeometryProxy) -> UnitPoint {
        let dir = layoutDirection(for: value)
        switch value.anchorMode {
        case .auto:
            let a = AnchorHelper.sourceAnchor(for: proxy[value.anchor], in: proxy.size)
            return dir == .rightToLeft ? a.invert(.horizontal) : a
        case .manual(let source, _ ): return source
        }
    }
    
    private func presentationAnchor(for value: Presentation, in proxy: GeometryProxy) -> UnitPoint {
        let dir = layoutDirection(for: value)
        switch value.metadata.anchorMode {
        case .auto:
            let a = AnchorHelper.presentationAnchor(for: proxy[value.anchor], in: proxy.size)
            return dir == .rightToLeft ? a.invert(.horizontal) : a
        case .manual(_, let presentation): return presentation
        }
    }
    
    private func dismiss() {
        guard let presentedValue else { return }
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            presentedValue.dispose()
        //}
    }
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(presentedValue != nil)
            .accessibilityHidden(presentedValue != nil)
            .onPreferenceChange(PresentationKey<Metadata>.self) { presentedValue = $0.last }
            .overlay {
                GeometryReader{ proxy in
                    let proxyWidth = proxy.size.width
                    
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        if let presentedValue = presentedValue {
                            let dir = layoutDirection(for: presentedValue)
                            let sourceFrame = proxy[presentedValue.anchor]
                            let presAnchor = presentationAnchor(for: presentedValue, in: proxy)
                            let sourceAnchor = sourceAnchor(for: presentedValue, in: proxy)
                            let presEdge = AnchorHelper.presentationEdge(for: presAnchor, and: sourceAnchor)
                            //let presAlignment = Alignment(presAnchor)
                            //let sourceAlignment = Alignment(sourceAnchor)
                            
                            presentedValue.metadata.view(.init(anchor: presAnchor, edge: presEdge ?? .bottom))
                                .environment(\._isBeingPresented, true)
                                .transition(
                                    .merge(.scale(0, anchor: presAnchor), .opacity)
                                    .animation(.bouncy)
                                )
                                .environment(\.dismissPresentation, .init(id: presentedValue.id, closure: dismiss))
                                .onPreferenceChange(PresentationBackgroundKey.self){ bgView = $0.last?.view }
                                .onPreferenceChange(PresentationBackgroundInteractionKey.self){ bgInteraction = $0.last }
                                .alignmentGuide(.leading){ dimension in
                                    let selfOffset = dimension.width * presAnchor.x
                                    
                                    let range = dir == .leftToRight ? [sourceFrame.minX, sourceFrame.maxX] : [sourceFrame.maxX, sourceFrame.minX]
                                    let sourceStart = ((range[1] - range[0]) * sourceAnchor.x) + range[0]
                                    
                                    if dir == .rightToLeft {
                                        return -(proxyWidth - (sourceStart + selfOffset))
                                    } else {
                                        return -(sourceStart - selfOffset)
                                    }
                                }
                                .alignmentGuide(.top){ dimension in
                                    let selfOffset = dimension.height * presAnchor.y
                                    
                                    let range = [sourceFrame.minY, sourceFrame.maxY]
                                    let sourceStart = ((range[1] - range[0]) * sourceAnchor.y) + range[0]
                                    
                                    return -(sourceStart - selfOffset)
                                }
                            }
                    }
                    //.environment(\.layoutDirection, layoutDirection())
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


public struct AnchorHelper {
    
    public static func presentationEdge(for presentationAnchor: UnitPoint, and sourceAnchor: UnitPoint) -> Edge? {
        
        if presentationAnchor.x == 0 && sourceAnchor.x == 1 {
            return .leading
        } else if presentationAnchor.x == 1 && sourceAnchor.x == 0 {
            return .trailing
        }
        
        if presentationAnchor.y == 0 && sourceAnchor.y == 1 {
            return .top
        } else if presentationAnchor.y == 1 && sourceAnchor.y == 0 {
            return .bottom
        }
        
        return nil
    }
    
    public static func sourceAnchor(for rect: CGRect, in size: CGSize) -> UnitPoint {
        let midX = size.width / 2
        let h: Double = rect.midX > midX ? 1 : rect.midX < midX ? 0 : 0.5
        let v: Double = rect.midY > size.height / 2 ? 0 : 1
        
        if size.height < size.width {
            return UnitPoint(x: h, y: v).inverse
        } else {
            return UnitPoint(x: h, y: v)
        }
    }
    
    public static func presentationAnchor(for rect: CGRect, in size: CGSize) -> UnitPoint {
        let midX = size.width / 2
        let h: Double = rect.midX > midX ? 1 : rect.midX < midX ? 0 : 0.5
        let v: Double = rect.midY > size.height / 2 ? 1 : 0
        
        return UnitPoint(x: h, y: v)
    }
    
}
