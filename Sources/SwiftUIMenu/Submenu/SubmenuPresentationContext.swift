import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct SubmenuPresentationContext {

    @State private var stack: [PresentationValue<SubmenuMetadata>] = []
    @State private var visuallyPresented: Set<UniqueID> = []
    
    private var presentedStack: [PresentationValue<SubmenuMetadata>] {
        stack.filter({ visuallyPresented.contains($0.id) })
    }
    
    let alignment: Alignment = .center
    
}

extension SubmenuPresentationContext: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            ZStack {
                content
                    .isBeingPresentedOn(!presentedStack.isEmpty)
                    .environment(\.presentationDepth, presentedStack.count)
                    .scaleEffect(1 - (Double(presentedStack.count) / 10), anchor: .init(alignment))
                    .windowDragDisabled(!stack.isEmpty)
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear.overlay(alignment: .center){
                        ForEach(stack){ item in
                            let i = stack.firstIndex(of: item)!
                            let visualIdx = presentedStack.firstIndex(where: { $0.id == item.id }) ?? i
                            let bounds = proxy[item.anchor]
                            let isLast = item.id == stack.last?.id
                            let isVisuallyPresented = visuallyPresented.contains(item.id)
                            let scale: Double = isLast ? 1 : 1 - (Double(visuallyPresented.count - (i + 1)) / 10)
                            
                            Color.clear.overlay(alignment: isVisuallyPresented ? .center : .top){
                                item.view
                                    .zIndex(Double(i))
                                    .presentationDismissHandler(enabled: visuallyPresented.contains(item.id)){
                                        visuallyPresented.remove(item.id)
                                        item.dispose()
                                    }
                                    .onChangePolyfill(of: item.wantsDisposal){
                                        visuallyPresented.remove(item.id)
                                    }
                                    .environment(\.presentationDepth, isLast ? 0 : presentedStack.count - (visualIdx + 1))
                                    .isBeingPresentedOn(!isLast)
                                    .environment(\._isBeingPresented, true)
                                    .transition(.identity)
                                    .background{
                                        if visuallyPresented.contains(item.id){
                                            // only dismiss after visual dismiss coordination
                                            Color.clear.onDisappear{
                                                stack.removeAll(where: { $0.id == item.id })
                                            }
                                        }
                                    }
                                    .onAppear{
                                        visuallyPresented.insert(item.id)
                                    }
                                    .offset(
                                        y: isVisuallyPresented ? 0 : bounds.minY
                                    )

                                    .scaleEffect(
                                        scale,
                                        anchor: .init(alignment)
                                    )
                                    .windowDragDisabled(!isLast)
                            }
                            .transition(.identity)
                        }
                    }
                }
            }
        }
        .presentationDismissHandler(.context, enabled: !visuallyPresented.isEmpty){
            visuallyPresented.removeAll()
        }
        .animation(.bouncy.speed(1.2), value: visuallyPresented)
        .presentationHandler(SubmenuMetadata.self){
            stack = $0
        }
    }
    
}

struct SubmenuMetadata: Equatable {
    
}


extension View {
    
    nonisolated public func submenuPresentationContext() -> some View {
        modifier(SubmenuPresentationContext())
    }
    
}


struct SubmenuToAlignmentAdaptor: Adaptable {
    
    func adapt(_ view: SubmenuMetadata) -> AnchorPresentationMetadata {
        .init(
            sortDate: Date(),
            type: .horizontal(preferredAlignment: .top),
            alignmentMode: .keepUntilInvalid,
            isLeader: true
        )
    }
    
}
