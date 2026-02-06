import SwiftUI

struct PresentationInteraction: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.coordinateSpace == rhs.coordinateSpace
    }
    
    let id: UUID
    let coordinateSpace: CoordinateSpace
    let value: Binding<CGPoint>
    
}

struct PresentationInteractionKey: PreferenceKey {
    
    typealias Value = PresentationInteraction?
    
    static func reduce(value: inout PresentationInteraction?, nextValue: () -> PresentationInteraction?) {
        if let next = nextValue() {
            value = next
        }
    }
    
}

extension View {
    
    func presentationInteraction(_ interaction: PresentationInteraction?) -> some View {
        preference(key: PresentationInteractionKey.self, value: interaction)
    }
    
    
}
