import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


extension NavView {
    
    struct Elements: View {
        
        @State private var popping: UniqueID?
        
        let size: CGSize?
        let resolve: (PresentationValue<Metadata>) -> CGRect
        let root: Root
        let rootID: UniqueID
        let elements: [PresentationValue<Metadata>]
        let elementsToAnimateRemoval: Set<UniqueID>
        let elementsShouldBeWrappedByNavBarContainer: Bool
        let elementWantsDisposal: (UniqueID) -> Void
        
        @ViewBuilder private func Subview(showBack: Bool, _ content: @escaping () -> some View) -> some View {
            if elementsShouldBeWrappedByNavBarContainer {
                NavBarContainer {
                    content()
                        .navBar(.leading, hidden: !showBack, priority: .max){
                            BackButton()
                                .transition(.moveEdge(.leading) + .opacity)
                        }
                }
            } else {
                content()
            }
        }
        
        var body: some View {
            let width: CGFloat = size?.width ?? .infinity
            let hasPresented = Set(elements.map(\.id)).subtracting(elementsToAnimateRemoval)
            let elementsVisible = elements.filter({
                !elementsToAnimateRemoval.contains($0.id) && $0.id != popping
            })

            let rootThawed = elementsVisible.isEmpty
            let rootIsPresented = !rootThawed//!elements.isEmpty || popping != nil && elements.count == 1
            
            ZStack(alignment: .leading) {
                Color.clear.overlay {
                    Subview(showBack: false){
                        root.navViewBreadcrumb(for: rootID, isActive: !hasPresented.isEmpty)
                    }
                    .interactionFollower(Transition.self, enabled: elements.count == 1)
                    .frozen(rootThawed ? .thawed : .frozenInvisible)
                }
                .zIndex(1)
                .isNavigatedOn(rootIsPresented)
                .isBeingPresentedOn(rootIsPresented)
                .navBarItemsRemoved(!elementsVisible.isEmpty)
                .geometryGroupIfAvailable()
                
                let poppingIndex = elements.firstIndex(where: { $0.id == popping })
                
                ForEach(elements){ element in
                    let index = elements.firstIndex(of: element)!
                    let isLast = element.id == elements.last?.id
                    let isLastVisible = element.id == elementsVisible.last?.id
                    let isPresentedOn = !isLast && (hasPresented.contains(elements.last!.id) || popping == element.id)
                    //let isBeforeLast = elements.count > 1 ? index == elements.indices.last! - 1 : false
                    let isBeforePopping = poppingIndex != nil ? index == poppingIndex! - 1 : false
                    let isThawed = isBeforePopping || isLast
    
                    Color.clear.overlay {
                        Subview(showBack: true){
                            element.view.navViewBreadcrumb(for: element.id, isActive: !isLast)
                        }
                        .navBarItemsRemoved(!isLastVisible)
                        .interactionFollower(Transition.self, enabled: isBeforePopping)
                        .frozen(isThawed ? .thawed : .frozenInvisible)
                    }
                    .zIndex(Double(index) + 2.0)
                    .interactionLeader(
                        enabled: isLast,
                        source: resolve(element),
                        width: width,
                        wantsRemoval: element.wantsDisposal || elementsToAnimateRemoval.contains(element.id)
                    ){ state in
                        switch state {
                        case .interacting:
                            popping = element.id
                        case .willComplete:
                            popping = element.id
                        case let .didComplete(dest):
                            popping = nil
                            if dest == .disappear {
                                elementWantsDisposal(element.id)
                            }
                        }
                    }
                    .geometryGroupIfAvailable()
                    .environment(\._isBeingPresented, true)
                    .isNavigatedOn(isPresentedOn)
                    .isBeingPresentedOn(!isThawed)
                }
            }
        }
    }
    
    
}
