import SwiftUI


public extension View {
    
    #if os(tvOS) || os(watchOS)
    
    func onHoverPolyfill(perform action: @escaping (Bool) -> Void) -> Self {
        self
    }
    
    #else
    
    func onHoverPolyfill(perform action: @escaping (Bool) -> Void) -> some View {
        onHover(perform: action)
    }
    
    #endif
    
}
