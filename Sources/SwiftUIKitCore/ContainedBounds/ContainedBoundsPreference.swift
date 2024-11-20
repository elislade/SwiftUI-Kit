import SwiftUI


struct ContainedBoundsPreference: Hashable {
    
    static func == (lhs: ContainedBoundsPreference, rhs: ContainedBoundsPreference) -> Bool {
        lhs.id == rhs.id && lhs.context == rhs.context && lhs.anchor == rhs.anchor
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    let context: AnyHashable
    let anchor: Anchor<CGRect>
    let didChangeVisibility: (ContainedBoundsState) -> Void
    
}


struct ContainedBoundsKey: PreferenceKey {
    
    typealias Value = [ContainedBoundsPreference]
    
    static var defaultValue: [ContainedBoundsPreference] { [] }
    
    static func reduce(value: inout [ContainedBoundsPreference], nextValue: () -> [ContainedBoundsPreference]) {
        value.append(contentsOf: nextValue())
    }
    
}
