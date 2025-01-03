import SwiftUI
import SwiftUIKitCore

struct SubmenuPresentationContext: ViewModifier {

    @State private var stack: [SubmenuPresentation] = []
    @State private var hasBeenPresented: Set<UUID> = []
    
    private var presentedStack:  [SubmenuPresentation] {
        stack.filter({ hasBeenPresented.contains($0.id) })
    }
    
    let alignment: Alignment = .center
    
    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            ZStack {
                content
                    .environment(\._isBeingPresentedOn, !presentedStack.isEmpty)
                    .environment(\.presentationDepth, presentedStack.count)
//                    .frame(maxHeight: !presentedStack.isEmpty ? 50 : nil)
                    .scaleEffect(1 - (Double(presentedStack.count) / 15), anchor: .init(alignment))
                    .disableWindowEvents(disable: !stack.isEmpty)
            }
            .overlay {
                GeometryReader { proxy in
                    ZStack {
                        Color.clear
                        ForEach(stack.indices, id: \.self){ i in
                            let resolvedBounds = proxy[stack[i].labelAnchor]
                            let isPresentedOn = hasBeenPresented.contains(stack[i].id) && i != stack.indices.last
                            let releventStack = hasBeenPresented.contains(stack[i].id) ? presentedStack : stack
                            
                            stack[i].menu()
                                .frame(width: resolvedBounds.width)
                                .environment(\.presentationDepth, releventStack.count - i - 1)
                                .environment(\._isBeingPresentedOn, isPresentedOn)
                                .environment(\._isBeingPresented, hasBeenPresented.contains(stack[i].id))
                                .environment(\.dismissPresentation, .init(id: stack[i].id, closure: {
                                    hasBeenPresented.remove(stack[i].id)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                        stack[i].dismiss()
                                    }
                                }))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                        hasBeenPresented.insert(stack[i].id)
                                    }
                                }
                                .offset(y: hasBeenPresented.contains(stack[i].id) ? 0 : resolvedBounds.midY - (proxy.size.height / 2))
                                .scaleEffect(
                                    1 - (Double(releventStack.count - i - 1) / 15) ,
                                    anchor: .init(alignment)
                                )
                                .disableWindowEvents(disable: i != stack.indices.last)
                        }
                    }
                }
            }
        }
        .animation(.bouncy, value: hasBeenPresented)
        //.animation(.bouncy, value: stack.count)
        .onPreferenceChange(SubmenuPresentationKey.self) {
            _stack.wrappedValue = $0
        }
    }
    
}


struct SubmenuPresentation: Identifiable, Equatable, Sendable {
    
    static func == (lhs: SubmenuPresentation, rhs: SubmenuPresentation) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let labelAnchor: Anchor<CGRect>
    let menu: @MainActor() -> AnyView
    let dismiss: @Sendable () -> Void
    
}


struct SubmenuPresentationKey: PreferenceKey {
    
    static var defaultValue: [SubmenuPresentation] { [] }
    
    static func reduce(value: inout [SubmenuPresentation], nextValue: () -> [SubmenuPresentation]) {
        value.append(contentsOf: nextValue())
    }

}
