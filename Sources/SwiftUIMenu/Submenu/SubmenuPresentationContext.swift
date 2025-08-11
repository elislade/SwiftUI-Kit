import SwiftUI
import SwiftUIKitCore

struct SubmenuPresentationContext: ViewModifier {

    @State private var stack: [SubmenuPresentation] = []
    @State private var visuallyPresented: Set<UUID> = []
    
    private var presentedStack: [SubmenuPresentation] {
        stack.filter({ visuallyPresented.contains($0.id) })
    }
    
    let alignment: Alignment = .center
    
    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            ZStack {
                content
                    .environment(\._isBeingPresentedOn, !presentedStack.isEmpty)
                    .environment(\.presentationDepth, presentedStack.count)
                    .scaleEffect(1 - (Double(presentedStack.count) / 10), anchor: .init(alignment))
                    .disableWindowDrag(!stack.isEmpty)
            }
            .overlay {
                GeometryReader { proxy in
                    ZStack {
                        Color.clear
                        
                        ForEach(stack, id: \.id){ item in
                            let i = stack.firstIndex(of: item)!
                            let bounds = proxy[item.anchor]
                            let isLast = item.id == stack.last?.id
                            let isVisuallyPresented = visuallyPresented.contains(item.id)
                            let scale: Double = isLast ? 1 : 1 - (Double((visuallyPresented.count) - (i + 1)) / 10)
                            item.menu()
                                .onCoordinatedDismiss {
                                    visuallyPresented.remove(item.id)
                                }
                                .frame(width: bounds.width + 12)
                                .environment(\.presentationDepth, isLast ? 0 : presentedStack.count - (i + 1))
                                .environment(\._isBeingPresentedOn, stack.last?.id != item.id)
                                .environment(\._isBeingPresented, true)
                                .transition(.identity)
                                .background{
                                    if visuallyPresented.contains(item.id){
                                        // only dismiss after visual dismiss coordination
                                        Color.clear.onDisappear{
                                            item.dismiss()
                                        }
                                    }
                                }
                                .onAppear{
                                    visuallyPresented.insert(item.id)
                                }
                                .offset(
                                    y: bounds.midY - (proxy.size.height / 2)
                                )
                                .offset(
                                    y: isVisuallyPresented ? -bounds.height * 0.6 : 0
                                )
                                .scaleEffect(
                                    scale,
                                    anchor: .init(alignment)
                                )
                                .disableWindowDrag(!isLast)
                        }
                    }
                }
            }
        }
        .animation(.bouncy, value: stack)
        .animation(.bouncy, value: visuallyPresented)
        .onPreferenceChange(SubmenuPresentationKey.self) {
            stack = $0
        }
    }
    
}


struct SubmenuPresentation: Identifiable, Equatable, Sendable {
    
    static func == (lhs: SubmenuPresentation, rhs: SubmenuPresentation) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let anchor: Anchor<CGRect>
    let menu: @MainActor() -> AnyView
    let dismiss: @Sendable () -> Void
    
}


struct SubmenuPresentationKey: PreferenceKey {
    
    static var defaultValue: [SubmenuPresentation] { [] }
    
    static func reduce(value: inout [SubmenuPresentation], nextValue: () -> [SubmenuPresentation]) {
        value.append(contentsOf: nextValue())
    }

}


public extension View {
    
    nonisolated func submenuPresentationContext() -> some View {
        modifier(SubmenuPresentationContext())
    }
    
}
