import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavView<Root: View, Transition: TransitionModifier> : View {

    @Namespace private var namespace
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let useNavBar: Bool
    private let root: Root
    
    @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    @State private var willDismiss: [PresentationWillDismissAction] = []
    
    @State private var scrollGestureTotal: Double = 0
    @State private var updatingStack = false
    @State private var resetting = false
    
    @GestureState(reset: { _, transaction in
        transaction.animation = .fastSpring
    }) private var transitionFraction: CGFloat = 0
    
    //@State private var transitionFraction: Double = 0
    @State private var isUpdatingTransition: Bool = false
    
    /// - Parameters:
    ///   - transition: The ``Transition`` to use for push/pop transitions.
    ///   - useNavBar: If true the root view will be wrapped in a ``NavBarContainer``. If false the navigation view will have no nav bar. Defaults to true.
    ///   - content: The view builder of the root view
    public init(
        transition: Transition.Type,
        useNavBar: Bool = true,
        content: @escaping () -> Root
    ){
        self.useNavBar = useNavBar
        self.root = content()
    }
    
    #if !os(tvOS)
    private func edgeDrag(size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged{ _ in
                isUpdatingTransition = true
            }
            .onEnded({ g in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                commitTransition(at: g.predictedEndTranslation.width * directionFactor)
            })
            .updating($transitionFraction){ gesture, state, transaction in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                state = max(gesture.translation.width * directionFactor, 0) / size.width
            }
    }
    #endif
    
    private func popElement() {
        guard let last = elements.last else { return }
        
        for action in willDismiss {
            action()
        }
        
        last.dispose()
    }
    
    private func commitTransition(at value: Double) {
        if value > 150 {
            // user dragged enough, pop element
            popElement()
        }
    }
    
    private var rootPushAmount: Double {
        guard elements.count <= 1 else { return 1 }
        
        if elements.isEmpty {
            return 0
        } else if isUpdatingTransition {
            return 1 - transitionFraction
        } else {
            return 1
        }
    }
    
    private func pushAmount(_ index: Int) -> Double {
        guard elements.count > 1 else { return 0 }
        
        if index == elements.indices.last {
            return 0
        } else if isUpdatingTransition && elements.indices.last?.advanced(by: -1) == index {
            return 1 - transitionFraction
        } else {
            return 1
        }
    }
    
    private func newElements(_ new: [PresentationValue<NavViewElementMetadata>]) {
        guard elements != new else { return }
        var elements = self.elements
        let diff = new.difference(from: elements, by: { $0.id == $1.id })

        for item in diff {
            switch item {
            case let .insert(_, element, _):
                elements.append(element)
            case let .remove(_, element, _):
                elements.removeAll(where: { $0.id == element.id })
            }
        }
        
        self.elements = elements
    }
    
    private var content: some View {
        InsetReader { insets in
            GeometryReader { proxy in
                let size = proxy.size
                var rootFrozen: FrozenState {
                    elements.isEmpty ? .thawed : elements.count > 1 ? .frozenInvisible : .frozen
                }
                
                root
                    .frozen(rootFrozen)
                    .modifier(Transition(pushAmount: rootPushAmount))
                    .zIndex(1)
                    .environment(\.presentationDepth, elements.count)
                    .isBeingPresentedOn(!elements.isEmpty)
                    .safeAreaInsets(insets)
                    .disableNavBarItems(!elements.isEmpty)
                    .disableOnPresentationWillDismiss(!elements.isEmpty)
                    .maskMatching(using: namespace, enabled: !elements.isEmpty)
                    .overlay {
                        ZStack(alignment: .leading) {
                            ForEach(elements, id: \.id){ ele in
                                let index = elements.firstIndex(of: ele)!
                                let isLast = index == elements.indices.last
                                let shouldDisable = !isLast
                                let shouldIgnore = index < (elements.count - 2)
                                
                                var frozenState: FrozenState {
                                    isLast ? .thawed : shouldIgnore ? .frozenInvisible : .frozen
                                }
                                
                                ele.view()
                                    .frozen(frozenState)
                                    .modifier(Transition(pushAmount: pushAmount(index)))
                                    .maskMatchingSource(using: namespace, enabled: isLast)
                                    .offset(
                                        x: isLast ? (transitionFraction) * size.width : 0
                                    )
                                    .zIndex(Double(index) + 2.0)
                                    .environment(\._isBeingPresented, isLast && isUpdatingTransition ? false : true)
                                    .environment(\.presentationDepth, (elements.count - 1) - index)
                                    .isBeingPresentedOn(!isLast)
                                    .disableNavBarItems(shouldDisable)
                                    .disableOnPresentationWillDismiss(!isLast)
                                    .safeAreaInsets(insets)
                                    .transition(.offset([size.width, 0]))
                                    .maskMatching(using: namespace, enabled: !isLast)
                            }
                            
                            Color.clear
                                .frame(width: 14)
                                .paddingAddingSafeArea(.leading)
                                .contentShape(Rectangle())
                                .zIndex(Double(elements.count + 3))
                                #if !os(tvOS)
                                .highPriorityGesture(edgeDrag(size: size), including: .gesture)
                                #endif
                                .allowsHitTesting(!elements.isEmpty && !resetting)
                                .defersSystemGesturesPolyfill(on: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .resetAction(active: !elements.isEmpty && !resetting){
                    Task {
                        resetting = true
                        defer { resetting = false }
                        while !elements.isEmpty {
                            popElement()
                            try await Task.sleep(nanoseconds: NSEC_PER_SEC / 200)
                        }
                    }
                }
                .mask {
                    Rectangle().ignoresSafeArea()
                }
                .navBar(elements.isEmpty ? .none : .leading){
                    Button{ popElement() } label: {
                        Label { Text("Go Back") } icon: {
                            Image(systemName: "arrow.left")
                                .layoutDirectionMirror()
                        }
                    }
                    .keyboardShortcut(SwiftUIKitCore.KeyEquivalent.escape, modifiers: [])
                    .labelStyle(.iconOnly)
                    .transition(.move(edge: .leading) + .opacity)
                }
                .animation(.fastSpringInterpolating.speed(resetting ? 1.5 : 1), value: elements)
//                .indirectGesture(IndirectScrollGesture(useMomentum: false, mask: .horizontal).onChanged{ g in
//                    let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
//                    scrollGestureTotal += g.delta.x
//                    updateTransition(value: scrollGestureTotal * directionFactor, in: proxy)
//                }.onEnded{ g in
//                    let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
//                    commitTransition(at: scrollGestureTotal * directionFactor)
//                    scrollGestureTotal = 0
//                })
                .handleDismissPresentation(popElement)
                .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self, perform: newElements)
                .resetPreference(PresentationKey<NavViewElementMetadata>.self)
            }
        }
        .geometryGroupPolyfill()
        .onPreferenceChange(PresentationWillDismissPreferenceKey.self){
            willDismiss = $0
        }
        .onAnimationComplete(when: transitionFraction == 0){
            isUpdatingTransition = false
        }
    }
    
    
    public var body: some View {
        Group {
            if useNavBar {
                NavBarContainer{
                    content
                }
                .ignoresSafeArea(edges: [.bottom, .horizontal])
            } else {
                content
                    .disableNavBarPreferences()
                    .ignoresSafeArea()
            }
        }
        .scrollPassthroughContext()
    }
    
}

public extension NavView where Transition == DefaultNavTransitionModifier {
    
    init(
        useNavBar: Bool = true,
        @ViewBuilder content: @escaping () -> Root
    ){
        self.init(
            transition: DefaultNavTransitionModifier.self,
            useNavBar: useNavBar,
            content: content
        )
    }
    
}


struct NavViewDestinationValueKey: PreferenceKey {
    
    static var defaultValue: [NavViewDestinationValue] { [] }
    
    static func reduce(value: inout [NavViewDestinationValue], nextValue: () -> [NavViewDestinationValue]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct NavViewDestinationValue: Equatable {
    
    static func == (lhs: NavViewDestinationValue, rhs: NavViewDestinationValue) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
    
    let id: UUID
    let value: AnyHashable
    let dispose: () -> Void
    
}
