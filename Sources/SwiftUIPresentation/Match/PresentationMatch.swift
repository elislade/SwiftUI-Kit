import SwiftUI
import SwiftUIKitCore


public extension View {
    
    func presentationMatchContext() -> some View {
        modifier(PresentationMatchContextModifier())
    }
    
    func presentationMatch<ID: Hashable>(_ id: ID) -> some View {
        PresentationMatchModifier(matchID: id, content: self)
    }
    
}
