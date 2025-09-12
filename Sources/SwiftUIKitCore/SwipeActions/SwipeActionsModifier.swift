import SwiftUI


struct SwipeActionsModifier<Leading: View, Trailing: View>: ViewModifier {
    
    @Environment(\.layoutDirection) private var direction
    @StateObject private var sharedState = SwipeActionsState.shared
    
    @State private var id = UUID()
    @State private var scroll: Double = 0
    @State private var gestureStart: Double?
    @State private var horizontalInteractionOffset: Double?
    @State private var leadingSize: CGFloat = 0
    @State private var trailingSize: CGFloat = 0
    
    @State private var internalActiveEdge: HorizontalEdge?
    private let externalActiveEdge: Binding<HorizontalEdge?>?
    
    private var activeEdgeBinding: Binding<HorizontalEdge?> {
        externalActiveEdge ?? $internalActiveEdge
    }
    
    private var activeEdge: HorizontalEdge? {
        activeEdgeBinding.wrappedValue
    }
    
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
    
    private var horizontalOffset: Double {
        if let horizontalInteractionOffset {
            return horizontalInteractionOffset
        } else if let activeEdge {
            switch activeEdge {
            case .leading: return leadingSize
            case .trailing: return trailingSize * -1.0
            }
        } else {
            return 0
        }
    }
    
    private var layoutFactor: Double { direction.scaleFactor }
    
    private func close() {
        guard activeEdge != nil else {
             return
        }

        withAnimation(.fastSpringInterpolating){
            activeEdgeBinding.wrappedValue = nil
            horizontalInteractionOffset = nil
        }
    }
    
    private func updateInteraction(offset: Double, layoutFactor: Double){
        let offset = (offset * layoutFactor)
        
        if let activeEdge {
            guard availableEdges.contains(.init(activeEdge)) else { return }
            
            let edgeSize = activeEdge == .leading ? leadingSize : trailingSize
            let edgeFactor = activeEdge == .leading ? 1.0 : -1.0
            let diff = edgeSize - (offset * edgeFactor)
            let isOverShooting = diff < 0
            let isUnderShooting = activeEdge == .leading ? offset < 0 : offset > 0
            
            if isOverShooting {
                horizontalInteractionOffset = (edgeSize * edgeFactor) - powRetainSign(diff * edgeFactor, 0.7)
            } else if isUnderShooting {
                horizontalInteractionOffset = powRetainSign(offset, 0.75)
            } else {
                horizontalInteractionOffset = offset
            }
        } else {
            // Set active edge based on direction
            if offset < 0 && availableEdges.contains(.trailing) {
                horizontalInteractionOffset = offset
                activeEdgeBinding.wrappedValue = .trailing
            } else if offset > 0 && availableEdges.contains(.leading) {
                horizontalInteractionOffset = offset
                activeEdgeBinding.wrappedValue = .leading
            }
        }
    }
    
    private func endInteraction(projectedOffset: Double){
        guard activeEdge != nil else { return }
        
        let projectedOffset = projectedOffset * layoutFactor
        
        withAnimation(.fastSpringInterpolating){
            self.horizontalInteractionOffset = nil
            
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
    
    #if !os(tvOS)
    private var contentGesture: some Gesture {
        DragGesture(minimumDistance: 25, coordinateSpace: .global)
            .onChanged { g in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                transaction.isContinuous = true
                
                withTransaction(transaction){
                    if let gestureStart {
                        let offset = g.location.x - gestureStart
                        updateInteraction(offset: offset, layoutFactor: layoutFactor)
                    } else {
                        gestureStart = g.location.x - (horizontalOffset * layoutFactor)
                    }
                }
            }
            .onEnded { g in
                withTransaction(.init()){
                    gestureStart = nil
                    endInteraction(projectedOffset: g.predictedEndTranslation.width)
                }
            }
    }
    #endif
    
    func body(content: Content) -> some View {
        content
            .offset(x: horizontalOffset)
            .contentShape(Rectangle())
            #if !os(tvOS)
            .simultaneousGesture(TapGesture().onEnded(close))
            .highPriorityGesture(contentGesture)
            #endif
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin.y.rounded() }){ _ in
                close()
            }
            .overlay {
                HStack(spacing: 0) {
                    if let activeEdge, activeEdge == .leading {
                        HStack(spacing: 1, content: { leading })
                            .onGeometryChangePolyfill(of: \.size.width){
                                leadingSize = $0
                            }
                            .clipShape(
                                Rectangle()
                                    .offset(x: min(-leadingSize + horizontalOffset, 0) * layoutFactor)
                            )
                            .transition(.identity)
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let activeEdge, activeEdge == .trailing {
                        HStack(spacing: 1, content: { trailing })
                            .onGeometryChangePolyfill(of: \.size.width){
                                trailingSize = $0
                            }
                            .clipShape(
                                Rectangle()
                                    .offset(x: max(trailingSize + horizontalOffset, 0) * layoutFactor)
                            )
                            .transition(.identity)
                    }
                }
                .buttonStyle(SwipeButtonStyle(didCallAction: close))
            }
            .animation(.fastSpringInterpolating, value: activeEdge)
//            .indirectGesture(
//                IndirectScrollGesture(useMomentum: false, mask: .horizontal)
//                    .onChanged{ value in
//                        if scroll == 0 {
//                            scroll += horizontalOffset
//                        }
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
            .onChangePolyfill(of: activeEdge){
                if activeEdge != nil {
                    Task {
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
                        sharedState.latestSwipeActionID = id
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


@MainActor final class SwipeActionsState: ObservableObject {
    static let shared = SwipeActionsState()
    
    private init(){}
    
    @Published var latestSwipeActionID: UUID?
    
}
