import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavView<Root: View, Transition: TransitionModifier> : View {

    @Namespace private var namespace
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let barMode: NavViewBarMode
    private let root: Root
    
    @State private var elements: [PresentationValue<NavViewElementMetadata>] = []
    @State private var scrollGestureTotal: Double = 0
    @State private var updatingStack = false
    
    @GestureState(resetTransaction: .init(animation: .smooth.speed(1.8))) private var gestureIsActive = false
    @FocusedValue(\.resign) private var resignFocus
    
    @State private var transitionFraction: Double = 0
    
    /// - Parameters:
    ///   - transition: The ``Transition`` to use for push/pop transitions.
    ///   - barMode: The ``NavViewBarMode`` wrapping behaviour to use.  Defaults to `container`.
    ///   - content: The view builder of the root view
    public init(
        transition: Transition.Type,
        barMode: NavViewBarMode = .container,
        content: @escaping () -> Root
    ){
        self.barMode = barMode
        self.root = content()
    }
    
    private func popElement() {
        guard let last = elements.last else { return }
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
    
    private var content: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Elements(
                size: size,
                root: root,
                elements: elements,
                transitionFraction: $transitionFraction,
                gestureIsActive: gestureIsActive,
                wrapWithBar: barMode == .element
            )
            .animation(.smooth.speed(1.8), value: elements)
            .resetActionContainer(active: !elements.isEmpty){ @MainActor in
                while !elements.isEmpty {
                    popElement()
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
                }
            }
            #if !os(tvOS)
            .overlay{
                GeometryReader { proxy in
                    Rectangle()
                        .frame(width: 14 + proxy.safeAreaInsets.leading)
                        .opacity(0)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
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
                        )
                        .allowsHitTesting(!elements.isEmpty)
                        .defersSystemGesturesPolyfill(on: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ignoresSafeArea()
                }
                .releaseContainerSafeArea()
            }
            #endif
            .navBar(elements.isEmpty || barMode != .container ? .none : .leading){
                BackButton()
                    .transition(.move(edge: .leading) + .opacity)
                    .handleDismissPresentation(popElement)
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
        }
        .geometryGroupPolyfill()
        .clipped()
        .captureContainerSafeArea()
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
            if barMode == .container {
                NavBarContainer{
                    content
                }
            } else {
                content
                    .disableNavBarPreferences()
            }
        }
        .scrollPassthroughContext()
        .onPreferenceChange(PresentationKey<NavViewElementMetadata>.self){ new in
            guard elements != new else { return }
            print("UPDATE", new.map(\.id))
            let difference = new.difference(from: elements, by: { $0.id == $1.id })
            if let newElements = elements.applying(difference) {
                
                if newElements.last?.id != self.elements.last?.id {
                    resignFocus?()
                }
                
                transitionFraction = 0
                elements = newElements
            }
        }
        .resetPreference(PresentationKey<NavViewElementMetadata>.self)
    }
    
    
    struct BackButton: View {
        
        @Environment(\.dismissPresentation) private var dismissPresentation
        
        var body: some View {
            Button{ dismissPresentation() } label: {
                Label { Text("Go Back") } icon: {
                    Image(systemName: "arrow.left")
                        .layoutDirectionMirror()
                }
            }
            .keyboardShortcut(SwiftUIKitCore.KeyEquivalent.escape, modifiers: [])
            .labelStyle(.iconOnly)
        }
    }
    
}

public extension NavView where Transition == DefaultNavTransitionModifier {
    
    init(
        barMode: NavViewBarMode = .container,
        @ViewBuilder content: @escaping () -> Root
    ){
        self.init(
            transition: DefaultNavTransitionModifier.self,
            barMode: barMode,
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


public enum NavViewBarMode: Hashable, Sendable, BitwiseCopyable, CaseIterable {
    
    /// NavBar will NOT wrap any view.
    case none
    
    /// NavBar will wrap whole container.
    case container
    
    /// NavBar willl wrap each element individually.
    case element
    
}
