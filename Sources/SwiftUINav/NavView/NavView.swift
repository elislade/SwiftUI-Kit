import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavView<Root: View, Transition: TransitionModifier> : View {

    @Namespace private var namespace
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let useNavBar: Bool
    private let root: Root
    
    @State private var hasPresented: Set<UUID> = []
    @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    @State private var willDismiss: [PresentationWillDismissAction] = []
    
    @State private var scrollGestureTotal: Double = 0
    @State private var updatingStack = false
    
    @GestureState(resetTransaction: .init(animation: .smooth.speed(1.8))) private var gestureIsActive = false
    @FocusedValue(\.resign) private var resignFocus
    
    @State private var transitionFraction: Double = 0
    //@State private var isUpdatingTransition: Bool = false
    
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
            .onChanged{ gesture in
                var transaction = Transaction()
                transaction.isContinuous = true
                transaction.animation = nil
                withTransaction(transaction){
                    transitionFraction = max(gesture.translation.width * layoutDirection.scaleFactor, 0) / size.width
                }
                //transitionFraction = max(gesture.translation.width * layoutDirection.scaleFactor, 0) / size.width
            }
            .onEnded({ g in
                commitTransition(at: g.predictedEndTranslation.width * layoutDirection.scaleFactor)
            })
            .updating($gestureIsActive){ _, state, transaction in
                transaction.animation = nil
                state = true
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
        else {
            withAnimation(.smooth.speed(1.8)){
                transitionFraction = 0
            }
        }
    }
    
    private var rootPushAmount: Double {
        guard elements.count <= 1 else { return 1 }
        
        if elements.isEmpty {
            return 0
        } else if gestureIsActive {
            return 1 - transitionFraction
        } else {
            return 1
        }
    }
    
    private func pushAmount(_ index: Int) -> Double {
        guard elements.count > 1 else { return 0 }
        
        if index == elements.indices.last {
            return 0
        } else if gestureIsActive && elements.indices.last?.advanced(by: -1) == index {
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
        
        if elements.last?.id != self.elements.last?.id {
            resignFocus?()
        }
        
        transitionFraction = 0
        self.elements = elements
    }
    
    private var content: some View {
        GeometryReader { proxy in
            let size = proxy.size
            var rootFrozen: FrozenState {
                elements.count < 2 ? .thawed : elements.count > 1 ? .frozenInvisible : .frozen
            }
            
            ZStack(alignment: .leading) {
                root
                    .accessibilityHidden(!elements.isEmpty)
                    .releaseContainerSafeArea()
                    .frozen(rootFrozen)
                    .modifier(Transition(pushAmount: rootPushAmount))
                    .zIndex(1)
                    .environment(\.presentationDepth, elements.count)
                    .isBeingPresentedOn(!elements.isEmpty && hasPresented.contains(elements.first!.id))
                    .disableNavBarItems(!elements.isEmpty && hasPresented.contains(elements.first!.id))
                    .disableOnPresentationWillDismiss(!elements.isEmpty)
                    //.maskMatching(using: namespace, enabled: !elements.isEmpty)
                    .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
      
                ForEach(elements, id: \.id){ ele in
                    let index = elements.firstIndex(of: ele)!
                    let isLast = index == elements.indices.last
                    let isBeforeLast = index == elements.indices.last! - 1
                    let shouldDisable = !isLast
                    let shouldIgnore = index < (elements.count - 2)
                    
                    var frozenState: FrozenState {
                        isLast || (isBeforeLast) ? .thawed : shouldIgnore ? .frozenInvisible : .frozen
                    }
                    
                    ele.view()
                        .accessibilityHidden(!isLast)
                        .releaseContainerSafeArea()
                        .frozen(frozenState)
                        .background{
                            if isLast {
                                Rectangle()
                                    .fill(.background)
                                    .shadow(radius: 20, x: -10, y: 0)
                            }
                        }
                        .modifier(Transition(pushAmount: pushAmount(index)))
                        //.maskMatchingSource(using: namespace, enabled: isLast)
                        .offset(
                            x: isLast ? (transitionFraction) * size.width : 0
                        )
                        .zIndex(Double(index) + 2.0)
                        .environment(\._isBeingPresented, isLast && gestureIsActive ? false : true)
                        .environment(\.presentationDepth, (elements.count - 1) - index)
                        .isBeingPresentedOn(!isLast && hasPresented.contains(elements.last!.id))
                        .disableNavBarItems(shouldDisable)
                        .disableOnPresentationWillDismiss(!isLast)
                        .transition(.offset([size.width + 50, 0]))
                        //.maskMatching(using: namespace, enabled: !isLast)
                        .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
                        .onDisappear{
                            transitionFraction = 0
                        }
                        .onDisappear{ hasPresented.remove(ele.id) }
                        .onAppear{ hasPresented.insert(ele.id) }
                }
            }
            .animation(.smooth.speed(1.8), value: elements)
            .resetActionContainer(active: !elements.isEmpty){ @MainActor in
                while !elements.isEmpty {
                    popElement()
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
                }
            }
            .overlay{
                #if !os(tvOS)
                GeometryReader { proxy in
                    Rectangle()
                        .frame(width: 14 + proxy.safeAreaInsets.leading)
                        .opacity(0)
                        .contentShape(Rectangle())
                        .highPriorityGesture(edgeDrag(size: size), including: .gesture)
                        .allowsHitTesting(!elements.isEmpty)
                        .defersSystemGesturesPolyfill(on: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ignoresSafeArea()
                }
                .releaseContainerSafeArea()
                #endif
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
//            .indirectGesture(IndirectScrollGesture(useMomentum: false, mask: .horizontal).onChanged{ g in
//                scrollGestureTotal += g.delta.x
//                isUpdatingTransition = true
//                transitionFraction = max(scrollGestureTotal * layoutDirection.scaleFactor, 0) / size.width
//            }.onEnded{ g in
//                commitTransition(at: scrollGestureTotal * layoutDirection.scaleFactor)
//                scrollGestureTotal = 0
//            })
            .handleDismissPresentation(popElement)
            .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self, perform: newElements)
            .resetPreference(PresentationKey<NavViewElementMetadata>.self)
        }
        .geometryGroupPolyfill()
        .clipped()
        .captureContainerSafeArea()
        .onPreferenceChange(PresentationWillDismissPreferenceKey.self){
            willDismiss = $0
        }
        .resetPreference(PresentationWillDismissPreferenceKey.self)
//        .onAnimationComplete(when: transitionFraction == 0){
//            isUpdatingTransition = false
//        }
        .onChangePolyfill(of: gestureIsActive){ old, new in
            if old && !new {
                transitionFraction = 0
            }
        }
    }
    
    
    public var body: some View {
        Group {
            if useNavBar {
                NavBarContainer{
                    content
                }
            } else {
                content
                    .disableNavBarPreferences()
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
