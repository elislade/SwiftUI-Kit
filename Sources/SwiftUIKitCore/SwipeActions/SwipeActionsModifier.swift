import SwiftUI

struct SwipeInteraction: Equatable, Sendable {
    let edge: HorizontalEdge
    let start: Double
    var current: Double
    
    init(edge: HorizontalEdge, start: Double) {
        self.edge = edge
        self.start = start
        self.current = start
    }
    
    var offset: Double {
        current - start
    }
}


struct SwipeActionsModifier<Leading: View, Trailing: View> {
    
    @Environment(\.invalidateSwipeWhenMoved) private var moveInvalidation
    @Environment(\.activeSwipeID) private var activeIDBinding
    @Environment(\.layoutDirection) private var direction
    
    @State private var id = UUID()
    @State private var openSize: CGFloat = 1
    @State private var internalActiveEdge: HorizontalEdge?
    @State private var scrollInteraction: SwipeInteraction?
    
    @GestureState private var dragInteraction: SwipeInteraction?
    
    private var interaction: SwipeInteraction? { scrollInteraction ?? dragInteraction }
    
    private let externalActiveEdge: Binding<HorizontalEdge?>?
    
    private var openEdgeBinding: Binding<HorizontalEdge?> {
        externalActiveEdge ?? $internalActiveEdge
    }
    
    private var activeID: UUID? {
        get { activeIDBinding.wrappedValue }
        nonmutating set { activeIDBinding.wrappedValue = newValue }
    }
    
    private var openEdge: HorizontalEdge? {
        get { openEdgeBinding.wrappedValue }
        nonmutating set { openEdgeBinding.wrappedValue = newValue }
    }
    
    private let leading: @MainActor () -> Leading
    private let trailing: @MainActor () -> Trailing
    private let availableEdges: HorizontalEdge.Set
    
    init(
        activeEdge: Binding<HorizontalEdge?>? = nil,
        @ViewBuilder leading: @MainActor @escaping () -> Leading,
        @ViewBuilder trailing: @MainActor @escaping () -> Trailing
    ) {
        self.leading = leading
        self.trailing = trailing
        self.externalActiveEdge = activeEdge
        self.availableEdges = [.leading, .trailing]
    }
    
    private func scaleFactor(for edge: HorizontalEdge) -> Double {
        switch edge {
        case .leading: 1
        case .trailing: -1
        }
    }
    
    private var horizontalOffset: Double {
        if let openEdge {
            let interactionOffset = (interaction?.offset ?? 0) * direction.scaleFactor
            return (openSize * scaleFactor(for: openEdge)) + interactionOffset
        } else if let interaction {
            return interaction.offset * direction.scaleFactor
        } else {
            return 0
        }
    }
    
    private func close() {
        guard openEdge != nil else {
             return
        }

        withAnimation(.fastSpringInterpolating){
            openEdge = nil
        }
    }
    
}

extension SwipeActionsModifier: ViewModifier  {
    
    func body(content: Content) -> some View {
        let _interaction = self.interaction
        let activeEdge = _interaction?.edge ?? openEdge
        let horizontalOffset: Double = {
            if let edge = _interaction?.edge {
                switch edge {
                case .leading:
                    self.horizontalOffset.rubberBand(outside: 0...openSize)
                case .trailing:
                    self.horizontalOffset.rubberBand(outside: -openSize...0)
                }
            } else {
                self.horizontalOffset
            }
        }()
        
        content
            .contentShape(Rectangle())
            .offset(x: horizontalOffset)
            .defersSystemGesturesPolyfill(on: .horizontal)
            #if !os(tvOS)
            .highPriorityGesture(
                TapGesture().onEnded(close),
                including: openEdge == nil ? .subviews : .gesture
            )
            .highPriorityGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { g in
                        let projectedOffset = g.predictedEndTranslation.width * direction.scaleFactor
                        
                        withAnimation(.bouncy){
                            if let activeEdge {
                                switch activeEdge {
                                case .leading:
                                    self.openEdge = projectedOffset < 50 ? nil : activeEdge
                                case .trailing:
                                    self.openEdge = projectedOffset > -50 ? nil : activeEdge
                                }
                            }
                        }
                    }
                    .updating($dragInteraction){ gesture, state, transaction in
                        if state == nil {
                            if let openEdge {
                                state = .init(edge: openEdge, start: gesture.location.x)
                            } else if gesture.translation.width * direction.scaleFactor < 0 && availableEdges.contains(.trailing) {
                                state = .init(edge: .trailing, start: gesture.location.x)
                            } else if gesture.translation.width * direction.scaleFactor > 0 && availableEdges.contains(.leading) {
                                state = .init(edge: .leading, start: gesture.location.x)
                            }
                        } else {
                            state?.current = gesture.location.x
                        }
                    }
            )
            #endif
            .background{
                if moveInvalidation {
                    Color.clear.onGeometryChangePolyfill(of: { $0.frame(in: .global).origin.y.rounded() }){ _ in
                        close()
                    }
                }
            }
            .indirectScrollGesture(
                IndirectScrollGesture(axes: .horizontal)
                    .onChanged{ value in
                        if scrollInteraction == nil {
                            if let openEdge {
                                scrollInteraction = .init(edge: openEdge, start: 0)
                            } else  {
                                if value.delta.x > 0 {
                                    scrollInteraction = .init(edge: .leading.invert(active: direction == .rightToLeft), start: 0)
                                } else if value.delta.x < 0 {
                                    scrollInteraction = .init(edge: .trailing.invert(active: direction == .rightToLeft), start: 0)
                                }
                            }
                        }
                        scrollInteraction?.current = value.translation.x
                    }
                    .onEnded{ value in
                        let projectedOffset = value.translation.x
                        if let activeEdge = openEdge {
                            switch activeEdge.invert(active: direction == .rightToLeft) {
                            case .leading:
                                if projectedOffset < 50 {
                                    self.openEdge = nil
                                }
                            case .trailing:
                                if projectedOffset > -50 {
                                    self.openEdge = nil
                                }
                            }
                        } else {
                            self.openEdge = scrollInteraction?.edge
                        }
                        scrollInteraction = nil
                    }
            )
            .background {
                HStack(spacing: 0) {
                    HStack(spacing: 4){
                        if let activeEdge, activeEdge == .leading {
                            leading()
                                .transition(.swipeAction)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .onGeometryChangePolyfill(of: \.size.width){ size in
                        guard activeEdge == .leading else { return }
                        openSize = size + 12
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 4){
                        if let activeEdge, activeEdge == .trailing {
                            trailing()
                                .transition(.swipeAction)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .onGeometryChangePolyfill(of: \.size.width){ size in
                        guard activeEdge == .trailing else { return }
                        openSize = size + 12
                    }
                }
                .buttonStyle(SwipeButtonStyle(didCallAction: close))
                .interactionHoverGroup(priority: .high)
            }
            .animation(.bouncy, value: activeEdge)
            .animation(.fastSpringInterpolating, value: horizontalOffset)
            .onChangePolyfill(of: activeID){
                if activeID != id {
                    close()
                }
            }
            .onChangePolyfill(of: activeEdge){
                if activeEdge != nil {
                    Task {
                        try await Task.sleep(for: .milliseconds(80))
                        activeID = id
                    }
                }
            }
            .accessibilityRepresentation{
                HStack {
                    content
                    leading()
                    trailing()
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
        
        self.leading = { EmptyView() }
        self.trailing = trailing
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
        
        self.leading = leading
        self.trailing = { EmptyView() }
        self.availableEdges = .leading
    }
    
}


extension EnvironmentValues {
    
    @Entry internal var activeSwipeID: Binding<UUID?> = .constant(nil)
    @Entry internal var invalidateSwipeWhenMoved: Bool = false
    
}


extension AnyTransition {
    
    @MainActor static let swipeAction: Self = .scale(0.8) + .opacity + .blur(radius: 5)
    
}
