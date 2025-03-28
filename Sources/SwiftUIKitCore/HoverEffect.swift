import SwiftUI


public extension View {
    
#if os(macOS) || os(watchOS)
    
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
    
    @ViewBuilder func hoverEffectPolyfill() -> some View {
        if #available(iOS 13.4, tvOS 16.0, visionOS 1.0, *) {
            hoverEffect()
        } else {
            self
        }
    }
    
    @ViewBuilder func hoverEffectLift() -> some View {
        if #available(iOS 13.4, tvOS 16.0, visionOS 1.0, *) {
            hoverEffect(.lift)
        } else {
            self
        }
    }
    
    @ViewBuilder func hoverEffectHighlight() -> some View {
        if #available(tvOS 17.0, *) {
            hoverEffect(.highlight)
        } else {
            self
        }
    }
    
#endif
    
}
