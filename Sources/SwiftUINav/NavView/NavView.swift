import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


/// Similar to deprecated SwiftUI  `NavigationView`.
public struct NavView<Root: View, Transition: TransitionProvider> : View {

    @Environment(\.layoutDirection) private var layoutDirection
    
    private let transition: Transition
    private let useNavBar: Bool
    private let root: Root
    
    @State private var id = UUID()
    @MainActor @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    
    @State private var scrollGestureTotal: Double = 0
    @State private var pendingReset = false
    @State private var transitionFraction: CGFloat = 0
    @State private var isUpdatingTransition: Bool = false
    
    private var backAction: (@Sendable () -> Void)? {
        elements.isEmpty ? Optional<@Sendable () -> Void>(nil) : Optional<@Sendable () -> Void>({
            DispatchQueue.main.async{
                popElement()
            }
        })
    }
    
    /// - Parameters:
    ///   - transition: The ``TransitionProvider`` to use for push/pop transitions.
    ///   - useNavBar: If true the root view will be wrapped in a ``NavBarContainer``. If false the navigation view will have no nav bar. Defaults to true.
    ///   - content: The view builder of the root view
    public init(
        transition: Transition,
        useNavBar: Bool = true,
        @ViewBuilder content: @escaping () -> Root
    ){
        self.transition = transition
        self.useNavBar = useNavBar
        self.root = content()
    }
    
    private func edgeDrag(in proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({ g in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                updateTransition(value: g.location.x * directionFactor, in: proxy)
            }).onEnded({ g in
                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
                commitTransition(at: g.predictedEndLocation.x * directionFactor)
            })
    }
    
    @MainActor private func popElement() {
        guard let last = elements.last else { return }
        last.dispose()
    }
    
    private func updateTransition(value: Double, in proxy: GeometryProxy) {
        if isUpdatingTransition == false {
            isUpdatingTransition = true
        }
        
        transitionFraction = value / proxy.size.width
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
    
    private func offset(_ index: Int, in proxy: GeometryProxy) -> CGFloat {
        index == elements.indices.last ? transitionFraction * proxy.size.width : 0
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
    
    private var content: some View {
        GeometryReader { proxy in
            let trailingInset = proxy.safeAreaInsets.trailing
            
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
                    .disableNavBarPreferences(!elements.isEmpty)
                
                ForEach(elements.indices, id: \.self){ index in
                    elements[index].view()
                        .modifier(detailModifier(index))
                        .allowsHitTesting(index == elements.indices.last)
                        .accessibilityHidden(index != elements.indices.last)
                        .opacity(elements.count - 2 > index ? 0 : 1)
                        .offset(x: elements.count - 2 > index ? -2000 : offset(index, in: proxy))
                        .zIndex(elements.count - 2 > index ? 1 : Double(index) + 2.0)
                        .environment(\._isBeingPresented, index == elements.indices.last)
                        .environment(\.presentationDepth, elements.count - index)
                        .isBeingPresentedOn(index != elements.indices.last)
                        .disableResetAction(index != elements.indices.last)
                        .disableNavBarPreferences(index != elements.indices.last)
                        .transitions(
                            .move(edge: .trailing).animation(.smooth),
                            .offset(x: trailingInset).animation(.smooth)
                        )
                }
                
                Color.clear
                    .frame(width: 14)
                    .contentShape(Rectangle())
                    .zIndex(Double(elements.count + 1) * 3)
                    .highPriorityGesture(edgeDrag(in: proxy), including: .gesture)
                    .allowsHitTesting(elements.isEmpty == false)
                    .defersSystemGesturesPolyfill(on: .leading)
            }
            .resetAction(active: !elements.isEmpty && !pendingReset){
                pendingReset = true
                popElement()
            }
            .animation(.fastSpringInterpolating, value: elements)
            .mask {
                Rectangle().ignoresSafeArea()
            }
//            .indirectGesture(IndirectScrollGesture().onChanged{ g in
//                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
//                scrollGestureTotal += g.deltaX
//                updateTransition(value: max(scrollGestureTotal, 0) * directionFactor, in: proxy)
//            }.onEnded{ g in
//                let directionFactor: Double = layoutDirection == .rightToLeft ? -1 : 1
//                commitTransition(at: scrollGestureTotal * directionFactor)
//                scrollGestureTotal = 0
//            })
            .handleDismissPresentation(id: id, action: popElement)
            .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self){ items in
                let diff = items.difference(from: self.elements, by: { $0.id == $1.id })
                
                for item in diff {
                    switch item {
                    case let .insert(_, element, _):
                        self.elements.append(element)
                    case let .remove(_, element, _):
                        self.elements.removeAll(where: { $0.id == element.id })
                    }
                }
                
                if pendingReset {
                    if elements.isEmpty {
                        pendingReset = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            popElement()
                        }
                    }
                }
            }
        }
    }
    
    
    public var body: some View {
        if useNavBar {
            NavBarContainer(backAction: backAction){
                content
            }
        } else {
            content
        }
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
