import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


/// Similar to deprecated SwiftUI  `NavigationView`.
public struct NavView<Root: View, Transition: TransitionProvider> : View {

    @Environment(\.layoutDirection) private var layoutDirection
    
    private let transition: Transition
    private let useNavBar: Bool
    private let root: Root
    
    @State private var backAction: BackAction = .none
    @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    @State private var willDismiss: [PresentationWillDismissAction] = []
    @State private var size: CGSize = .zero
    
    @State private var scrollGestureTotal: Double = 0
    @State private var pendingReset = false
    @State private var transitionFraction: CGFloat = 0
    @State private var isUpdatingTransition: Bool = false
    
    /// - Parameters:
    ///   - transition: The ``TransitionProvider`` to use for push/pop transitions.
    ///   - useNavBar: If true the root view will be wrapped in a ``NavBarContainer``. If false the navigation view will have no nav bar. Defaults to true.
    ///   - content: The view builder of the root view
    public init(
        transition: Transition,
        useNavBar: Bool = true,
        content: @escaping () -> Root
    ){
        self.transition = transition
        self.useNavBar = useNavBar
        self.root = content()
    }
    
    private func edgeDrag() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({ g in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                updateTransition(value: max(g.translation.width * directionFactor, 0))
            }).onEnded({ g in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                commitTransition(at: g.predictedEndTranslation.width * directionFactor)
            })
    }
    
    private func popElement() {
        guard let last = elements.last else { return }
        
        for action in willDismiss {
            action()
        }
        
        last.dispose()
    }
    
    private func updateTransition(value: Double) {
        transitionFraction = value / size.width
        if isUpdatingTransition == false {
            isUpdatingTransition = true
        }
    }
    
    private func commitTransition(at value: Double) {
        if value > 150 {
            // user dragged enough
            // dispose of the transition element
            // after completing the animation

            popElement()
            withAnimation(.fastSpringInterpolating.delay(0.1)) {
                transitionFraction = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                isUpdatingTransition = false
            }
        } else {
            // user did not drag enough
            // reinstate the transition element
            // after rolling back the animation
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                withAnimation(.fastSpringInterpolating) {
                    transitionFraction = 0
                } completion: {
                    isUpdatingTransition = false
                }
            } else {
                withAnimation(.fastSpringInterpolating) {
                    transitionFraction = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    isUpdatingTransition = false
                }
            }
        }
    }
    
    private func offset(_ index: Int) -> CGFloat {
        index == elements.indices.last ? transitionFraction * size.width : 0
    }
    
    private var baseModifier: Transition.TransitionModifier {
        guard elements.count <= 1 else { return transition.modifier(.progress(1)) }
        
        if elements.isEmpty {
            return transition.identity
        } else if isUpdatingTransition {
            return transition.modifier(.progress(1 - transitionFraction))
        } else {
            return transition.modifier(.progress(1))
        }
    }
    
    private func detailModifier(_ index: Int) -> Transition.TransitionModifier {
        guard elements.count > 1 else { return transition.identity }
        
        if index == elements.indices.last {
            return transition.modifier(percent: 0)
        } else if isUpdatingTransition && elements.count - 2 == index {
            return transition.modifier(percent: 1 - transitionFraction)
        } else {
            return transition.modifier(percent: 1)
        }
    }
    
    private nonisolated func newElements(_ new: [PresentationValue<NavViewElementMetadata>]) {
        guard _elements.wrappedValue != new else { return }
        var elements = self._elements.wrappedValue
        let diff = new.difference(from: elements, by: { $0.id == $1.id })

        for item in diff {
            switch item {
            case let .insert(_, element, _):
                elements.append(element)
            case let .remove(_, element, _):
                elements.removeAll(where: { $0.id == element.id })
            }
        }

        self._elements.wrappedValue = elements
    }
    
    private var content: some View {
        InsetReader { insets in
            GeometryReader { proxy in
                //let trailingInset = proxy.safeAreaInsets.trailing
                
                ZStack(alignment: .topLeading) {
                    root
                        .modifier(baseModifier)
                        .allowsHitTesting(elements.isEmpty)
                        .opacity(elements.count > 1 ? 0 : 1)
                        .accessibilityHidden(!elements.isEmpty)
                        .zIndex(1)
                        .environment(\.presentationDepth, elements.count)
                        .isBeingPresentedOn(!elements.isEmpty)
                        .disableResetAction(!elements.isEmpty)
                        .safeAreaInsets(insets)
                        .disableInsetReading(isUpdatingTransition ? true : !elements.isEmpty)
                        .disableNavBarPreferences(!elements.isEmpty)
                        .disableOnGeometryChanges(!elements.isEmpty)
                        .disableOnPresentationWillDismiss(!elements.isEmpty)
                        .scrollOffsetDisabled(!elements.isEmpty)
                        .onGeometryChangePolyfill(of: \.size){ size = $0 }
                        .overlay {
                            ZStack {
                                ForEach(elements, id: \.id){ ele in
                                    let index = elements.firstIndex(of: ele)!
                                    let isLast = index == elements.indices.last
                                    let shouldDisable = !isLast
                                    let shouldIgnore = index < (elements.count - 2)
                                    
                                    var isDisabled: Bool {
                                        isUpdatingTransition ? shouldIgnore : shouldDisable
                                    }
                                    
                                    ele.view()
                                        .modifier(detailModifier(index))
                                        .offset(x: isDisabled ? 0 : offset(index))
                                        .accessibilityHidden(shouldDisable)
                                        .opacity(shouldIgnore ? 0 : 1)
                                        .zIndex(Double(index) + 2.0)
                                        .environment(\._isBeingPresented, isLast && isUpdatingTransition ? false : true)
                                        .environment(\.presentationDepth, elements.count - index)
                                        .isBeingPresentedOn(!isLast)
                                        .disableResetAction(shouldDisable)
                                        .disableNavBarPreferences(shouldDisable)
                                        .safeAreaInsets(insets)
                                        .disableInsetReading(shouldIgnore)
                                        .disableOnPresentationWillDismiss(!isLast)
                                        .allowsHitTesting(!shouldDisable)
                                        .scrollOffsetDisabled(shouldDisable)
                                        .transition(
                                            .offset([size.width, 0])
                                        )
                                }
                            }
                        }
                    
                    Color.clear
                        .frame(width: 14)
                        .paddingAddingSafeArea(.leading)
                        .contentShape(Rectangle())
                        .zIndex(Double(elements.count + 3))
                        .highPriorityGesture(edgeDrag(), including: .gesture)
                        .allowsHitTesting(elements.isEmpty == false)
                        .defersSystemGesturesPolyfill(on: .leading)
                }
                .resetAction(active: !elements.isEmpty && !pendingReset){
                    pendingReset = true
                    popElement()
                }
                .mask {
                    Rectangle().ignoresSafeArea()
                }
                .animation(.fastSpringInterpolating.speed(pendingReset ? 1.5 : 1), value: elements)
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
                .onChangePolyfill(of: elements){
                    backAction.visible = !elements.isEmpty
                    
                    if pendingReset {
                        if elements.isEmpty {
                            pendingReset = false
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                                popElement()
                            }
                        }
                    }
                }
                .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self){ items in
                    self.newElements(items)
                }
            }
        }
        .onPreferenceChange(PresentationWillDismissPreferenceKey.self){
            _willDismiss.wrappedValue = $0
        }
    }
    
    
    public var body: some View {
        Group {
            if useNavBar {
                NavBarContainer(backAction: backAction){
                    content
                }
                .ignoresSafeArea(edges: [.bottom, .horizontal])
                .onAppear {
                    backAction.action = popElement
                }
            } else {
                content
                    .ignoresSafeArea()
            }
        }
        .scrollOffsetContext()
    }
    
}


public extension NavView where Transition == DefaultNavTransitionProvider {
    init(
        useNavBar: Bool = true,
        @ViewBuilder content: @escaping () -> Root
    ){
        self.init(
            transition: DefaultNavTransitionProvider(),
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


struct DisableViewDrawingModifier: ViewModifier {
    
    @State private var size: CGSize = .zero
    
    var isDisabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .accessibilityHidden(isDisabled)
            .opacity(isDisabled ? 0 : 1)
            .disabled(isDisabled)
            .disableResetAction(isDisabled)
            .disableNavBarPreferences(isDisabled)
            .disableInsetReading(isDisabled)
            .disableOnGeometryChanges(isDisabled)
            .allowsHitTesting(!isDisabled)
            .scrollOffsetDisabled(isDisabled)
            .onGeometryChangePolyfill(of: \.size){
                if !isDisabled {
                    size = $0
                }
            }
            .frame(
                maxWidth: isDisabled ? size.width : nil,
                maxHeight: isDisabled ? size.height : nil
            )
    }
    
}
