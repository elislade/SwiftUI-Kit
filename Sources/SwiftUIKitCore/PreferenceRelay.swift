import SwiftUI


public extension View {
    
    func preferenceRelay<Key: PreferenceKey>(_ key: Key.Type) -> some View  where Key.Value : Equatable {
        modifier(PreferenceRelaySource<Key>())
    }
    
    nonisolated func preferenceRelayReceiver<Key: PreferenceKey>(_ key: Key.Type) -> some View  where Key.Value : Equatable {
        modifier(PreferenceRelay<Key>())
    }
    
}


struct PreferenceRelaySource<Key: PreferenceKey>: ViewModifier where Key.Value: Equatable {
    
    @State private var id = UUID()
    
    @Environment(\.parent?.preferenceValueRelay) private var parent
    @Environment(\.preferenceValueRelay) private var direct
    
    init(){}
    
    private var relay: (UUID, Any) -> Void {
        parent ?? direct
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(Key.self){ relay(id, $0) }
            .onDisappear{ relay(id, Key.defaultValue) }
            .resetPreference(Key.self)
    }
    
}


struct PreferenceRelay<Key: PreferenceKey> where Key.Value: Equatable {
    
    @State private var relay: [UUID: Key.Value] = [:]
    
    nonisolated init(){}
    
}


extension PreferenceRelay : ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .environment(\.preferenceValueRelay){ id, value in
                if let value = value as? Key.Value {
                    relay[id] = value
                }
            }
            .background{
                Color.clear.preference(
                    key: Key.self,
                    value: relay.values.reduce(into: Key.defaultValue){ value, next in
                        Key.reduce(value: &value){ next }
                    }
                )
            }
    }
    
}


extension EnvironmentValues {
    
    @Entry internal var preferenceValueRelay: (UUID, Any) -> Void = { _, _ in }
    
}
