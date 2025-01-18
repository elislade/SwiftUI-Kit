import SwiftUI


public extension View {
    
#if os(macOS)
    
    func hoverEffectPolyfill() -> Self {
        self
    }
    
    func hoverEffectLift() -> Self {
        self
    }
    
    func hoverEffectHighlight() -> Self {
        self
    }
    
#else
    
    func hoverEffectPolyfill() -> some View {
        hoverEffect()
    }
    
    func hoverEffectLift() -> some View {
        hoverEffect(.lift)
    }
    
    func hoverEffectHighlight() -> some View {
        hoverEffect(.highlight)
    }
    
#endif
    
}
