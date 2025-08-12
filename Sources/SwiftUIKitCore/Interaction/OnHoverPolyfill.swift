import SwiftUI


public extension View {
    
    #if os(tvOS) || os(watchOS)
    
    nonisolated func onHoverPolyfill(perform action: @escaping (Bool) -> Void) -> Self {
        self
    }
    
    #else
    
    nonisolated func onHoverPolyfill(perform action: @escaping (Bool) -> Void) -> some View {
        onHover(perform: action)
    }
    
    #endif
    
}
