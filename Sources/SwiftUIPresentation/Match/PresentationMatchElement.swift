import SwiftUI
import SwiftUIKitCore


struct PresentationMatchKey: PreferenceKey {
    
    typealias Value = [MatchGroup]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let next = nextValue()
        
        for n in next {
            if let index = value.firstIndex(where: {
                $0.matchID == n.matchID && $0.destination == nil && $0.id != n.id
            }) {
                value[index].destination = n.source
            }
            
            value.append(n)
        }
    }
    
}


struct MatchGroup: Equatable {
    
    struct Element: Equatable, Sendable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.anchor == rhs.anchor && lhs.id == rhs.id
        }
        
        var id: Int = 0
        let anchor: Anchor<CGRect>
        let view: @MainActor () -> AnyView
        @Binding var isVisible: Bool
    }
    
    let id: UUID
    let matchID: AnyHashable
    let source: Element
    var destination: Element?
    
}
