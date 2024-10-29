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
    
    @inlinable func hoverEffectPolyfill() -> some View {
        hoverEffect()
    }
    
    @inlinable func hoverEffectLift() -> some View {
        hoverEffect(.lift)
    }
    
    @inlinable func hoverEffectHighlight() -> some View {
        hoverEffect(.highlight)
    }
    
#endif
    
}
