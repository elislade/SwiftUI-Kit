import SwiftUI


struct FrozenStateModifier: ViewModifier {
    
    @State private var frozenSize: CGSize?
    @Environment(\.frozenState) private var state
    
    func body(content: Content) -> some View {
        content
            .background{
                GeometryReader{ proxy in
                    Color.clear.onChangePolyfill(of: state.isFrozen, initial: true){
                        if state.isFrozen {
                            frozenSize = proxy.size
                        } else {
                            frozenSize = nil
                        }
                    }
                }
            }
            .allowsHitTesting(state.isThawed)
            .opacity(state == .frozenInvisible ? 0 : 1)
            .accessibilityHidden(state.isFrozen)
            .frame(
                width: frozenSize?.width,
                height: frozenSize?.height
            )
            .disableAnimations(state == .frozenInvisible)
            .scrollPassthroughDisabled(state.isFrozen)
    }
    
}
