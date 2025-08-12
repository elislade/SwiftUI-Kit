import SwiftUI


public extension View {
    
#if os(macOS) || os(watchOS)
    
    nonisolated func hoverEffectPolyfill() -> Self {
        self
    }
    
    nonisolated func hoverEffectLift() -> Self {
        self
    }
    
    nonisolated func hoverEffectHighlight() -> Self {
        self
    }
    
#else
    
    @ViewBuilder nonisolated func hoverEffectPolyfill() -> some View {
        if #available(iOS 13.4, tvOS 16.0, visionOS 1.0, *) {
            hoverEffect()
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func hoverEffectLift() -> some View {
        if #available(iOS 13.4, tvOS 16.0, visionOS 1.0, *) {
            hoverEffect(.lift)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func hoverEffectHighlight() -> some View {
        if #available(tvOS 17.0, *) {
            hoverEffect(.highlight)
        } else {
            self
        }
    }
    
#endif
    
}
