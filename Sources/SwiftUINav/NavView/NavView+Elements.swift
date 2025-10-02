import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


extension NavView {
    
    struct Elements: View {
        
        @State private var hasPresented: Set<UUID> = []
        
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
        
        let size: CGSize
        let root: Root
        let elements: [PresentationValue<NavViewElementMetadata>]
        @Binding var transitionFraction: Double
        let gestureIsActive: Bool
        let wrapWithBar: Bool
        
        @ViewBuilder private func view<V: View>(_ content: V, showBack: Bool) -> some View {
            if wrapWithBar {
                NavBarContainer {
                    content
                        .navBar(showBack ? .leading : .none){
                            BackButton()
                                .transition(.move(edge: .leading) + .opacity)
                        }
                }
            } else {
                content
            }
        }
        
        var body: some View {
            var rootPushAmount: Double {
                guard elements.count <= 1 else { return 1 }
                
                if elements.isEmpty {
                    return 0
                } else if gestureIsActive {
                    return 1 - transitionFraction
                } else {
                    return 1
                }
            }
            
            var rootFrozen: FrozenState {
                elements.count < 2 ? .thawed : elements.count > 1 ? .frozenInvisible : .frozen
            }
            
            ZStack(alignment: .leading) {
                view(root, showBack: false)
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
                    .frame(maxWidth: size.width, maxHeight: size.height)
      
                ForEach(elements, id: \.id){ element in
                    let index = elements.firstIndex(of: element)!
                    let isLast = index == elements.indices.last
                    let isBeforeLast = index == elements.indices.last! - 1
                    let shouldDisable = !isLast
                    let shouldIgnore = index < (elements.count - 2)
                    
                    var frozenState: FrozenState {
                        isLast || (isBeforeLast) ? .thawed : shouldIgnore ? .frozenInvisible : .frozen
                    }
                    
                    view(element.view, showBack: true)
                        .accessibilityHidden(!isLast)
                        .releaseContainerSafeArea()
                        .frozen(frozenState)
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
                        .frame(maxWidth: size.width, maxHeight: size.height)
//                        .onDisappear{
//                            transitionFraction = 0
//                        }
                        .onDisappear{ hasPresented.remove(element.id) }
                        .onAppear{ hasPresented.insert(element.id) }
                }
            }
        }
    }
    
    
}
