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
    @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    
//    @State private var destinationValues: [NavViewDestinationValue] = []
//    @State private var pendingDestinationValues: [NavViewDestinationValue] = []
    
    @State private var transitionFraction: CGFloat = 0
    @State private var isUpdatingTransition: Bool = false
    @State private var indirectScrollTotal = 0.0
    
    
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
    
    private func popElement() {
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
    
    private func offset(_ detail: PresentationValue<NavViewElementMetadata>, in proxy: GeometryProxy) -> CGFloat {
        detail.id == elements.last?.id ? transitionFraction * proxy.size.width : 0
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
    
    private func detailModifier(_ detail: PresentationValue<NavViewElementMetadata>) -> Transition.TransitionModifier {
        guard elements.count > 1 else { return transition.identity }
        
        if detail.id == elements.last?.id {
            return transition.modifier(percent: 0)
        } else if isUpdatingTransition && elements[elements.count - 2].id == detail.id {
            return transition.modifier(percent: 1 - transitionFraction)
        } else {
            return transition.modifier(percent: 1)
        }
    }
    
    private var content: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                root
                    .modifier(baseModifier)
                    .allowsHitTesting(elements.isEmpty)
                    .accessibilityHidden(!elements.isEmpty)
                    .zIndex(1)
                    .environment(\.presentationDepth, elements.count)
                    .isBeingPresentedOn(!elements.isEmpty)
                    .disableResetAction(!elements.isEmpty)
                    .disableNavBarPreferences(!elements.isEmpty)
                
                ForEach(elements.indices, id: \.self){ index in
                    let element = elements[index]
                    element.view
                        .modifier(detailModifier(element))
                        .allowsHitTesting(element.id == elements.last?.id)
                        .accessibilityHidden(index != elements.indices.last)
                        .offset(x: offset(element, in: proxy))
                        .zIndex(Double(index) + 2.0)
                        .environment(\._isBeingPresented, index == elements.indices.last)
                        .environment(\.presentationDepth, elements.count - index)
                        .isBeingPresentedOn(index != elements.indices.last)
                        .disableResetAction(element.id != elements.last?.id)
                        .disableNavBarPreferences(element.id != elements.last?.id)
                        .transitions(
                            .move(edge: .trailing).animation(.smooth),
                            .offset(x: proxy.safeAreaInsets.trailing).animation(.smooth)
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
            .resetAction(active: !elements.isEmpty){
                Task.detached {
                    let elements = elements.reversed()
                    for element in elements {
                        element.dispose()
                        while element.id == self.elements.last?.id { }
                        usleep(10_000)
                    }
                }
            }
            .animation(.fastSpringInterpolating, value: elements)
            .mask {
                Rectangle().ignoresSafeArea()
            }
            //.environment(\.destinationNavValue, pendingDestinationValues.last)
            .handleDismissPresentation(id: id, action: popElement)
//            .onPreferenceChange(NavViewElementPreferenceKey.self){ v in
//                self.elements = v.sorted(by: { $0.date < $1.date })
//            }
//            .onPreferenceChange(NavViewDestinationValueKey.self){
//                self.destinationValues = $0
//            }
            .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self){
                let diff = $0.difference(from: self.elements, by: { $0.id == $1.id })
                
                for insert in diff.insertions {
                    switch insert {
                    case .insert(_, let element, _):
                        self.elements.append(element)
                    case .remove: continue
                    }
                }
                
                for removal in diff.removals {
                    switch removal {
                    case .insert: continue
                    case .remove(_, let element, _):
                        self.elements.removeAll(where: { $0.id == element.id })
                    }
                }
            }
        }
    }
    
    
    public var body: some View {
        if useNavBar {
            NavBarContainer(backAction: elements.isEmpty ? nil : popElement){
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
