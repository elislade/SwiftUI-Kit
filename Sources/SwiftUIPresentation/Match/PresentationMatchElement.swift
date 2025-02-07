import SwiftUI
import SwiftUIKitCore


struct PresentationMatchElement: Equatable, @unchecked Sendable, Identifiable {
    
    static func == (lhs: PresentationMatchElement, rhs: PresentationMatchElement) -> Bool {
        lhs.id == rhs.id &&
        lhs.matchID == rhs.matchID &&
        lhs.isDestination == rhs.isDestination &&
        lhs.anchor == rhs.anchor
    }
    
    let id: UUID
    let matchID: AnyHashable
    let isDestination: Bool
    let anchor: Anchor<CGRect>
    let view: @MainActor () -> AnyView
    let visibility: @Sendable (Bool) -> Void
    
}


struct PresentationMatchKey: PreferenceKey {
    
    typealias Value = [PresentationMatchElement]
    
    static var defaultValue: Value{ [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
