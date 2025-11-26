import SwiftUI
import SwiftUIKitCore


struct PresentationMatchContextModifier: ViewModifier {
    
    @State private var indexWantsTop: Int?
    
    func body(content: Content) -> some View {
        content.overlayPreferenceValue(PresentationMatchKey.self){ groups in
            ZStack{
                ForEach(groups, id: \.id) { group in
                    let index = groups.firstIndex(where: { $0.id == group.id })!
                    GroupView(group: group){
                        indexWantsTop = index
                    }
                    .zIndex(Double(indexWantsTop == index ? groups.count + 1 : index))
                }
            }
        }
    }
    
    
    struct GroupView: View {
        
        enum Direction: Equatable {
            case opening
            case closeing
            
            var isOpening: Bool { self == .opening }
            var isClosing: Bool { self == .closeing }
        }
        
        let group: MatchGroup
        let requestTopIndex: () -> Void
        
        @State private var activeDestination: MatchGroup.Element?
        @State private var direction: Direction = .opening
        @State private var isAwaitingRemoval = false
        
        var body: some View {
            ZStack {
                Color.clear
                if let activeDestination {
                    Content(
                        showViews: direction.isClosing,
                        source: group.source,
                        destination: activeDestination,
                        direction: direction,
                    ){
                        if direction == .opening {
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
                        direction = .closeing
                        requestTopIndex()
                        activeDestination = old
                    }
                    return
                }
                
                if let new {
                    direction = .opening
                    if activeDestination == nil {
                        requestTopIndex()
                    }
                    activeDestination = new
                } else {
                    requestTopIndex()
                    direction = .closeing
                }
            }
        }
        
        
        struct Content: View {
            
            @State private var sourceOrigin: SIMD2<Double> = .zero
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
                                    
                                    if direction == .closeing {
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
                                    .offsetBinding(
                                        $sourceOrigin,
                                        identity: .constant(dst.origin.simd)
                                    )
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
                                    .offsetBinding(
                                        $sourceOrigin,
                                        identity: .constant(dst.origin.simd)
                                    )
                                    +
                                    .opacity(0, identity: 1)
                                )
                        } else {
                            Color.clear.onDisappear{
                                if direction == .opening {
                                    finished()
                                }
                            }
                        }
                    }
                    .animation(.fastSpring, value: showViews)
                    .onChangePolyfill(of: src.origin, initial: true){
                        sourceOrigin = src.origin.simd
                    }
                    .onChangePolyfill(of: direction, initial: true){
                        if direction == .closeing {
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

