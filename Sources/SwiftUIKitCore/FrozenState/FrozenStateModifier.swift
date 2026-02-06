import SwiftUI


struct FrozenStateModifier: ViewModifier {
    
    @Environment(\.frozenState) private var state
    
    func body(content: Content) -> some View {
        content
            .sizeFrozen(state.isFrozen)
            .allowsHitTesting(state.isThawed)
            .opacity(state == .frozenInvisible ? 0 : 1)
            .accessibilityHidden(!state.isThawed)
            .disableAnimations(state == .frozenInvisible)
            .scrollPassthroughDisabled(state.isFrozen)
    }
    
}


struct SizeFrozenModifier: ViewModifier {
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    
    let axesFrozen: Axis.Set
    
    func body(content: Content) -> some View {
        content
            .frame(
                width: width,
                height: height,
                alignment: .topLeading
            )
            .background{
                GeometryReader{ proxy in
                    Color.clear.onChangePolyfill(of: axesFrozen, initial: true){
                        if axesFrozen.contains(.horizontal) && proxy.size.width > 0 {
                            width = proxy.size.width
                        } else {
                            width = nil
                        }
                        
                        if axesFrozen.contains(.vertical) && proxy.size.height > 0{
                            height = proxy.size.height
                        } else {
                            height = nil
                        }
                    }
                }
            }
    }
    
}


extension View {
    
    nonisolated public func sizeFrozen(_ axes: Axis.Set) -> some View {
        modifier(SizeFrozenModifier(axesFrozen: axes))
    }
    
    nonisolated public func sizeFrozen(_ isFrozen: Bool) -> some View {
        modifier(SizeFrozenModifier(axesFrozen: isFrozen ? [.horizontal, .vertical] : []))
    }
    
}
