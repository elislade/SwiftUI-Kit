import SwiftUI


struct SwipeActionsModifier<Leading: View, Trailing: View>: ViewModifier {
    
    @Environment(\.layoutDirection) private var direction
    @StateObject private var sharedState = SwipeActionsState.shared
    
    @State private var id = UUID()
    @State private var scroll: Double = 0
    @State private var gestureOffset: Double?
    @State private var lastOpenOffset: CGFloat = 0
    @State private var contentY: CGFloat = 0
    @State private var contentYActivated: CGFloat = 0
    @State private var leadingSize: CGFloat = 0
    @State private var trailingSize: CGFloat = 0
    @State private var minDistanceFactor: CGFloat?
    
    @State private var internalActiveEdge: HorizontalEdge?
    private let externalActiveEdge: Binding<HorizontalEdge?>?
    
    private var activeEdgeBinding: Binding<HorizontalEdge?> {
        externalActiveEdge ?? $internalActiveEdge
    }
    
    private var activeEdge: HorizontalEdge? {
        activeEdgeBinding.wrappedValue
    }
    
    private let gestureMinMovement: CGFloat = 25
    private let leading: Leading
    private let trailing: Trailing
    private let availableEdges: HorizontalEdge.Set
    
    init(
        activeEdge: Binding<HorizontalEdge?>? = nil,
        @ViewBuilder leading: @MainActor @escaping () -> Leading,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
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
        
        self.externalActiveEdge = activeEdge
        self.availableEdges = set
    }
    
    private var totalOffset: Double {
        if let gestureOffset {
            return gestureOffset
        } else if let activeEdge {
            switch activeEdge {
            case .leading: return leadingSize
            case .trailing: return trailingSize * -1.0
            }
        } else {
            return 0
        }
    }
    
    private var layoutFactor: Double { direction == .leftToRight ? 1 : -1 }
    
    private func close() {
        guard activeEdge != nil && contentY != .zero else {
             return
        }

        withAnimation(.fastSpringInterpolating){
            activeEdgeBinding.wrappedValue = nil
            gestureOffset = nil
            minDistanceFactor = nil
        }
    }
    
    private func updateInteraction(offset: Double, layoutFactor: Double){
        let offset = (offset * layoutFactor) + lastOpenOffset
        
        if let activeEdge {
            guard availableEdges.contains(.init(activeEdge)) else { return }
            
            let edgeSize = activeEdge == .leading ? leadingSize : trailingSize
            let edgeFactor = activeEdge == .leading ? 1.0 : -1.0
            let diff = edgeSize - (offset * edgeFactor)
            let isOverShooting = diff < 0
            let isUnderShooting = activeEdge == .leading ? offset < 0 : offset > 0
            
            if isOverShooting {
                gestureOffset = (edgeSize * edgeFactor) - powRetainSign(diff * edgeFactor, 0.7)
            } else if isUnderShooting {
                gestureOffset = powRetainSign(offset, 0.75)
            } else {
                gestureOffset = offset
            }
        } else {
            // Set active edge based on direction
            if offset < 0 && availableEdges.contains(.trailing) {
                gestureOffset = offset
                activeEdgeBinding.wrappedValue = .trailing
            } else if offset > 0 && availableEdges.contains(.leading) {
                gestureOffset = offset
                activeEdgeBinding.wrappedValue = .leading
            }
        }
    }
    
    private func endInteraction(projectedOffset: Double){
        let projectedOffset = projectedOffset * layoutFactor
        lastOpenOffset = activeEdge == .leading ? leadingSize : trailingSize * -1
        
        withAnimation(.fastSpringInterpolating){
            self.gestureOffset = nil
            
            if let activeEdge {
                switch activeEdge {
                case .leading:
                    if projectedOffset < 50 {
                        activeEdgeBinding.wrappedValue = nil
                    }
                case .trailing:
                    if projectedOffset > -50 {
                        activeEdgeBinding.wrappedValue = nil
                    }
                }
            }
        }
    }
    
    private var contentGesture: some Gesture {
        DragGesture(minimumDistance: gestureMinMovement, coordinateSpace: .global)
            .onChanged { g in
                if minDistanceFactor == nil {
                    minDistanceFactor = activeEdge == nil ? g.translation.width < 0 ? -1.0 : 1 : 0
                }
                // Gesture translation starts from `minimumDistance` and not `zero`.
                // This is to compensate for that to have as smooth start as possible
                let offsetTravelledWhileDecidingToRecognize = gestureMinMovement * minDistanceFactor!
                updateInteraction(offset: g.translation.width - offsetTravelledWhileDecidingToRecognize, layoutFactor: layoutFactor)
            }
            .onEnded { g in
                endInteraction(projectedOffset: g.predictedEndTranslation.width)
                minDistanceFactor = nil
            }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: totalOffset)
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded(close))
            .highPriorityGesture(contentGesture)
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin.y.rounded() }){ contentY = $0 }
            .overlay {
                HStack(spacing: 0) {
                    if let activeEdge, activeEdge == .leading {
                        HStack(spacing: 1, content: { leading })
                            .onGeometryChangePolyfill(of: { $0.size.width }){
                                leadingSize = $0
                                
                                if gestureOffset == nil {
                                    lastOpenOffset = $0
                                }
                            }
                            .clipShape(
                                Rectangle()
                                    .offset(x: min(-leadingSize + totalOffset, 0) * layoutFactor)
                            )
                            .transitions(.asymmetric(
                                insertion: .identity,
                                removal: .move(edge: .leading).animation(.smooth)
                            ))
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let activeEdge, activeEdge == .trailing {
                        HStack(spacing: 1, content: { trailing })
                            .onGeometryChangePolyfill(of: { $0.size.width.rounded() }){
                                trailingSize = $0
                                
                                if gestureOffset == nil {
                                    lastOpenOffset = $0 * -1
                                }
                            }
                            .clipShape(
                                Rectangle()
                                    .offset(x: max(trailingSize + totalOffset, 0) * layoutFactor)
                            )
                            .transitions(.asymmetric(
                                insertion: .identity,
                                removal: .move(edge: .trailing).animation(.smooth)
                            ))
                    }
                }
                .buttonStyle(ButtonStyle(didCallAction: close))
            }
            .animation(.fastSpringInterpolating, value: activeEdge)
//            .indirectGesture(
//                IndirectScrollGesture(useMomentum: false, mask: .horizontal)
//                    .onChanged{ value in
//                        scroll += value.delta.x
//                        updateInteraction(offset: scroll, layoutFactor: 1)
//                    }
//                    .onEnded{ _ in
//                        endInteraction(projectedOffset: scroll)
//                        scroll = 0
//                    }
//            )
            .onChangePolyfill(of: sharedState.latestSwipeActionID){
                if sharedState.latestSwipeActionID != id {
                    close()
                }
            }
            .onChangePolyfill(of: abs(contentY - contentYActivated) > 10){
                close()
            }
            .onChangePolyfill(of: activeEdge){
                if activeEdge != nil {
                    contentYActivated = contentY
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        sharedState.latestSwipeActionID = id
                    }
                } else {
                    lastOpenOffset = 0
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
        isActive: Binding<Bool>? = nil,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ){
        if let isActive {
            self.externalActiveEdge = Binding(isActive, onValue: .trailing).transaction(isActive.transaction)
        } else {
            self.externalActiveEdge = nil
        }
        
        self.leading = EmptyView()
        self.trailing = trailing()
        self.availableEdges = .trailing
    }
    
}


extension SwipeActionsModifier where Trailing == EmptyView {
    
    init(
        isActive: Binding<Bool>? = nil,
        @ViewBuilder leading: @MainActor @escaping() -> Leading
    ){
        if let isActive {
            self.externalActiveEdge = Binding(isActive, onValue: .leading).transaction(isActive.transaction)
        } else {
            self.externalActiveEdge = nil
        }
        
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
