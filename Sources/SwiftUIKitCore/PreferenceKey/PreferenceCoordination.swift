import SwiftUI


struct PreferenceCoordinator<Key: PreferenceKey> where Key.Value: Equatable {
    
    @State private var targets: [CoordinatedPreference<Key>] = []
    
}

extension PreferenceCoordinator: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .preferenceChangeConsumer(CoordinatedPreferenceKey<Key>.self){ targets = $0 }
            .onPreferenceChange(Key.self){ value in
                for target in targets {
                    target.handle(value)
                }
            }
            .preferenceKeyReset(Key.self, reset: !targets.isEmpty)
    }
    
}


struct CoordinatedPreference<Key: PreferenceKey>: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UniqueID
    let handle: (Key.Value) -> Void
    
}


struct CoordinatedPreferenceKey<Key: PreferenceKey>: PreferenceKey {
    
    static var defaultValue: [CoordinatedPreference<Key>] { [] }
    
    static func reduce(value: inout [CoordinatedPreference<Key>], nextValue: () -> [CoordinatedPreference<Key>]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct CoordinatedPreferenceListener<Key: PreferenceKey> {
    
    @State private var id = UniqueID()
    let action: (Key.Value) -> Void
    
}

extension CoordinatedPreferenceListener: ViewModifier {
    
    func body(content: Content) -> some View {
        content.preference(
            key: CoordinatedPreferenceKey<Key>.self,
            value: [.init(id: id, handle: action)]
        )
    }
    
}


extension View {
    
    nonisolated public func onCoordinatedPreference<Key: PreferenceKey>(_ key: Key.Type = Key.self, perform action: @escaping (Key.Value) -> Void) -> some View {
        modifier(CoordinatedPreferenceListener<Key>(action: action))
    }
    
    /// Coordinates this Key with a listener in a sibling/cousin branch as opposed to the parent only preference chain.
    nonisolated public func preferenceCoordinator<Key: PreferenceKey>(_ key: Key.Type) -> some View where Key.Value : Equatable {
        modifier(PreferenceCoordinator<Key>())
    }
    
}
