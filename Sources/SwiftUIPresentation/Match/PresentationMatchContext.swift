import SwiftUI
import SwiftUIKitCore


struct PresentationMatchContextModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.overlayPreferenceValue(PresentationMatchKey.self){ groups in
            ZStack{
                ForEach(groups, id: \.id) { group in
                    let index = groups.firstIndex(where: { $0.id == group.id })!
                    GroupView(group: group)
                        .zIndex(Double(index))
                }
            }
            .preferenceKeyReset(PresentationKey<BasicPresentationMetadata>.self)
            .preferenceKeyReset(PresentationKey<AnchorPresentationMetadata>.self)
            .preferenceKeyReset(PresentationKey<FocusPresentationMetadata>.self)
            .preferenceKeyReset(BackdropPreferenceKey.self)
        }
        .preferenceKeyReset(PresentationMatchKey.self)
    }
    
    
    struct GroupView: View {
        
        enum Direction: Equatable {
            case appearing
            case disappearing
            
            var isAppearing: Bool { self == .appearing }
            var isDisappearing: Bool { self == .disappearing }
        }
        
        let group: MatchGroup
        
        @State private var activeDestination: MatchGroup.Element?
        @State private var direction: Direction = .appearing
        @State private var isAwaitingRemoval = false
        
        var body: some View {
            Color.clear.overlay{
                if let activeDestination {
                    Content(
                        showViews: direction.isDisappearing,
                        source: group.source,
                        destination: activeDestination,
                        direction: direction,
                    ){
                        if direction == .appearing {
                            isAwaitingRemoval = true
                        } else {
                            isAwaitingRemoval = false
                        }
                        
                        self.activeDestination = nil
                    }
                    .transition(.identity)
                }
            }
            .onChangePolyfill(of: group.destination, initial: true){ old, new in
                if isAwaitingRemoval {
                    if old != nil, new == nil {
                        direction = .disappearing
                        activeDestination = old
                    }
                    return
                }
               
                if let new {
                    direction = .appearing
                    activeDestination = new
                } else {
                    direction = .disappearing
                }
            }
        }
        
        
        struct Content: View {
            
            //@State private var sourceOrigin: SIMD2<Double> = .zero
            @State var showViews = false
            
            let source: MatchGroup.Element
            let destination: MatchGroup.Element
            let direction: Direction
            let finished: () -> Void
            
            var body: some View {
                GeometryReader { proxy in
                    let src = proxy[source.anchor]
                    let dst = proxy[destination.anchor]
                    
                    ZStack(alignment: .topLeading) {
                        Color.clear.zIndex(1)
                        
                        if showViews {
                            Color.clear.opacity(0)
                                .zIndex(2)
                                .onAppear{
                                    source.isVisible = false
                                    destination.isVisible = false
                                }
                                .onDisappear{
                                    destination.isVisible = true
                                    
                                    if direction == .disappearing {
                                        source.isVisible = true
                                        finished()
                                    }
                                }

                            source
                                .view()
                                .zIndex(3)
                                .frame(width: src.width, height: src.height)
                                .allowsHitTesting(false)
                                .transition(
                                    .scale(
                                        [1,1],
                                        identity: dst.size.simd / src.size.simd,
                                        anchor: .topLeading
                                    )
                                    +
                                    .offset(src.origin.simd, identity: dst.origin.simd)
                                    +
                                    .opacity(1, identity: 0)
                                )
                            
                            destination
                                .view()
                                .zIndex(4)
                                .allowsHitTesting(false)
                                .frame(width: dst.width, height: dst.height)
                                .transition(
                                    .scale(
                                        src.size.simd / dst.size.simd,
                                        anchor: .topLeading
                                    )
                                    +
                                    .offset(src.origin.simd, identity: dst.origin.simd)
                                    +
                                    .opacity(0, identity: 1)
                                )
                        } else {
                            Color.clear.onDisappear{
                                if direction == .appearing {
                                    finished()
                                }
                            }
                        }
                    }
                    .animation(.fastSpring, value: showViews)
//                    .onChangePolyfill(of: src.origin, initial: true){
//                        sourceOrigin = src.origin.simd
//                    }
                    .onChangePolyfill(of: direction, initial: true){
                        if direction == .disappearing {
                            showViews = false
                        } else {
                            showViews = true
                        }
                    }
                }
            }
        }
    }
    
    
}

