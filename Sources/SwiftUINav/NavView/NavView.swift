import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct NavView<Root: View, Transition: TransitionModifier> : View {

    typealias Metadata = NavViewElementMetadata
    
    @FocusedValue(\.resign) private var resignFocus
    @Namespace private var namespace

    @State private var rootID = UniqueID()
    @State private var elementsRemovalSnapshot: [PresentationValue<Metadata>]?
    @State private var elements: [PresentationValue<Metadata>] = []
    
    private let barMode: NavViewBarMode
    private let root: Root
    
    private var elementsNotRemoving: [PresentationValue<Metadata>] {
        elementsRemovalSnapshot ?? elements
    }
    
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
    
    private func pop(to element: UniqueID) {
        let elements = elementsNotRemoving
        guard !elements.isEmpty, element != elements.last?.id else { return }
        
        var snap: [PresentationValue<Metadata>] = []
        
        if element == rootID {
            for element in elements {
                if element.id == elements.last?.id {
                    snap.append(element)
                }
                element.dispose()
            }
        } else if let index = elements.firstIndex(where: { $0.id == element }) {
            for (idx, element) in elements.enumerated() {
                if idx <= index || element.id == elements.last?.id {
                    snap.append(element)
                }
                  
                if idx > index {
                    element.dispose()
                }
            }
        }
        
        if !snap.isEmpty { elementsRemovalSnapshot = snap }
    }
    
    private func popLast() {
        pop(to: elementsNotRemoving.dropLast().last?.id ?? rootID)
    }

    private var content: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            let size = CGSizeMake(
                proxy.size.width + insets.leading + insets.trailing,
                proxy.size.height + insets.bottom + insets.top
            )
            
            Elements(
                size: size,
                resolve: { proxy[$0.source ?? $0.anchor] },
                root: root,
                rootID: rootID,
                elements: elementsRemovalSnapshot ?? elements,
                elementsToAnimateRemoval: Set([elementsRemovalSnapshot?.last].compactMap{ $0?.id }),
                elementsShouldBeWrappedByNavBarContainer: barMode == .element
            ){ elementToRemove in
                elements.removeAll(where: { $0.id == elementToRemove })
                elementsRemovalSnapshot = nil
            }
            .resetActionContainer(active: !elements.isEmpty){ @MainActor in
                pop(to: rootID)
            }
            .navBar(.leading, hidden: elements.isEmpty || barMode != .container, priority: .max){
                BackButton()
                    .transition(
                        .moveEdge(.leading).animation(.bouncy)
                        + .opacity.animation(.linear(duration: 0.25))
                    )
                    .presentationDismissHandler(perform: popLast)
            }
            .presentationDismissHandler(.context, enabled: !elements.isEmpty, perform: popLast)
        }
    }
    
    
    public var body: some View {
        ZStack {
            if barMode == .container {
                NavBarContainer{
                    content
                }
            } else {
                content.navBarRemoved()
            }
        }
        .environment(\.navViewBreadcrumbs, from: NavViewBreadcrumbs.self)
        .environment(\.navViewDismissAction){ targetID in
            pop(to: targetID)
        }
        .scrollPassthroughContext()
        .interactionContext()
        .presentationHandler(Metadata.self){ values in
            let new = values.sorted(by: { $0.sortDate < $1.sortDate })
            
            // If the last element on the stack is different we are either poping or pushing a new element so resignFocus/firstResponder
            // This allows the keyboard to dismiss while the transition is happening instead of after.
            if new.last?.id != self.elements.last?.id {
                resignFocus?()
            }

            self.elements = new
        }
    }
    
}

extension NavView where Transition == DefaultNavTransitionModifier {
    
    public init(
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


public enum NavViewBarMode: Hashable, Sendable, BitwiseCopyable, CaseIterable {
    
    /// NavBar will NOT wrap any view.
    case none
    
    /// NavBar will wrap whole container.
    case container
    
    /// NavBar willl wrap each element individually.
    case element
    
}
