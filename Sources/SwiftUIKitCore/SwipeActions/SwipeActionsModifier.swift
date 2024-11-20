import SwiftUI


struct SwipeActionsModifier<Leading: View, Trailing: View>: ViewModifier {
    
    @Environment(\.layoutDirection) private var direction
    @StateObject private var sharedState = SwipeActionsState.shared
    
    @State private var contentYActivted: CGFloat = 0
    @State private var id = UUID()
    @State private var gestureOffset: Double?
    @State private var contentRect: CGRect = .zero
    @State private var leadingSize: CGSize = .zero
    @State private var trailingSize: CGSize = .zero
    @State private var activeEdge: HorizontalEdge?
    
    @Binding private var activeEdges: HorizontalEdge.Set
    
    private let leading: Leading
    private let trailing: Trailing
    private let availableEdges: HorizontalEdge.Set
    
    init(
        activeEdge: Binding<HorizontalEdge.Set> = .constant([]),
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.leading = leading()
        self.trailing = trailing()
        
        var set = HorizontalEdge.Set()
        
        if type(of: leading()) != EmptyView.self {
            set.insert(.leading)
        }
        
        if type(of: trailing()) != EmptyView.self {
            set.insert(.trailing)
        }
        
        self._activeEdges = activeEdge
        self.availableEdges = set
    }
    
    private var totalOffset: Double {
        if let gestureOffset {
            return gestureOffset
        } else if let activeEdge {
            switch activeEdge {
            case .leading: return leadingSize.width
            case .trailing: return trailingSize.width * -1.0
            }
        } else {
            return 0
        }
    }
    
    private var edgeFactor: Double {
        guard let activeEdge else { return 1 }
        switch activeEdge {
        case .leading: return 1
        case .trailing: return -1
        }
    }
    
    private var layoutFactor: Double { direction == .leftToRight ? 1 : -1 }
    
    private func close() {
        guard activeEdge != nil && contentRect != .zero else {
             return
        }
        
        activeEdge = nil
        gestureOffset = nil
    }
    
    private var contentGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onChanged{ g in
                if let activeEdge {
                    guard availableEdges.contains(.init(activeEdge)) else { return }
                    
                    gestureOffset = g.translation.width * layoutFactor
                    
                    let value = g.translation.width * layoutFactor
 
                    if activeEdge == .leading {
                        let diff = leadingSize.width - (g.translation.width * layoutFactor)
                       
                        if diff < 0 {
                            // If gesture is overshooting direction, scale the gesture translation with resistance.
                            gestureOffset = leadingSize.width + powRetainSign(diff, 0.7) * -1
                        } else if g.translation.width * layoutFactor < 0 {
                            // If gesture is undershooting in wrong direction, scale the gesture translation with resistance.
                            gestureOffset = powRetainSign(value, 0.75)
                        }
                    } else if activeEdge == .trailing {
                        let diff = trailingSize.width - (g.translation.width * -1 * layoutFactor)
                        
                        if diff < 0 {
                            // If gesture is overshooting direction, scale the gesture translation with resistance.
                            gestureOffset = -trailingSize.width + powRetainSign(diff, 0.7)
                        } else if g.translation.width * layoutFactor > 0 {
                            // If gesture is undershooting in wrong direction, scale the gesture translation with resistance.
                            gestureOffset = powRetainSign(value, 0.75)
                        }
                    }
                } else {
                    // Set active edge based on gesture direction
                    if g.translation.width * layoutFactor < -1 * layoutFactor && availableEdges.contains(.trailing) {
                        gestureOffset = g.translation.width * layoutFactor
                        activeEdge = .trailing
                    } else if g.translation.width * layoutFactor > 1 * layoutFactor && availableEdges.contains(.leading) {
                        gestureOffset = g.translation.width * layoutFactor
                        activeEdge = .leading
                    }
                }
                
                
            }
            .onEnded { g in
                self.gestureOffset = nil
                
                let projectedOffset = g.predictedEndTranslation.width * layoutFactor
                
                if let activeEdge {
                    switch activeEdge {
                    case .leading:
                        if projectedOffset < 50 {
                            self.activeEdge = nil
                        }
                    case .trailing:
                        if projectedOffset > -50 {
                            self.activeEdge = nil
                        }
                    }
                }
            }
    }
    
    
    func body(content: Content) -> some View {
        content
            .offset(x: totalOffset)
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded(close))
            .boundsReader(readingToRect: $contentRect)
            .highPriorityGesture(contentGesture)
            .overlay {
                HStack(spacing: 0) {
                    if let activeEdge, activeEdge == .leading {
                        HStack(spacing: 1, content: { leading })
                            .boundsReader(readingToSize: $leadingSize)
                            .clipShape(
                                Rectangle()
                                    .offset(x: min(-leadingSize.width + totalOffset, 0) * layoutFactor)
                            )
                            .transitions(.move(edge: .leading).animation(.smooth))
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let activeEdge, activeEdge == .trailing {
                        HStack(spacing: 1, content: { trailing })
                            .boundsReader(readingToSize: $trailingSize)
                            .clipShape(
                                Rectangle()
                                    .offset(x: max(trailingSize.width + totalOffset, 0) * layoutFactor)
                            )
                            .transitions(.move(edge: .trailing).animation(.smooth))
                    }
                }
                .buttonStyle(ButtonStyle(didCallAction: close))
            }
            .animation(gestureOffset == nil ? .fastSpringInterpolating : .fastSpringInteractive, value: totalOffset)
            .clipShape(ContainerRelativeShape())
            .onChangePolyfill(of: sharedState.latestSwipeActionID){
                if sharedState.latestSwipeActionID != id {
                    close()
                }
            }
            .onChangePolyfill(of: abs(contentRect.origin.y - contentYActivted) > 10){
                close()
            }
            .onChangePolyfill(of: activeEdge){
                if let activeEdge {
                    activeEdges = .init(activeEdge)
                    contentYActivted = contentRect.origin.y
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        sharedState.latestSwipeActionID = id
                    }
                } else {
                    activeEdges = []
                }
            }
            .onChangePolyfill(of: activeEdges, initial: true){      
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    if activeEdges == .leading {
                        if availableEdges.contains(.leading) {
                            activeEdge = .leading
                        } else {
                            activeEdges = []
                        }
                    } else if activeEdges == .trailing {
                        if availableEdges.contains(.trailing) {
                            activeEdge = .trailing
                        } else {
                            activeEdges = []
                        }
                    } else {
                        activeEdge = nil
                    }
                }
            }
            .accessibilityRepresentation{
                HStack {
                    content
                    leading
                    trailing
                }
                .accessibilityElement(children: .combine)
            }
    }
    
}


extension SwipeActionsModifier where Leading == EmptyView {
    
    init(
        isActive: Binding<Bool> = .constant(false),
        @ViewBuilder trailing: @escaping() -> Trailing
    ){
        self._activeEdges = .init(get: {
            isActive.wrappedValue ? .trailing : []
        }, set: {
            isActive.wrappedValue = $0.contains(.trailing)
        })
        
        self.leading = EmptyView()
        self.trailing = trailing()
        self.availableEdges = .trailing
    }
    
}


extension SwipeActionsModifier where Trailing == EmptyView {
    
    init(
        isActive: Binding<Bool> = .constant(false),
        @ViewBuilder leading: @escaping() -> Leading
    ){
        self._activeEdges = .init(get: {
            isActive.wrappedValue ? .leading : []
        }, set: {
            isActive.wrappedValue = $0.contains(.leading)
        })
        self.leading = leading()
        self.trailing = EmptyView()
        self.availableEdges = .leading
    }
    
}


final class SwipeActionsState: ObservableObject {
    @MainActor static let shared = SwipeActionsState()
    
    private init(){}
    @Published var latestSwipeActionID: UUID?
    
}
