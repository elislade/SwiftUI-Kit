import SwiftUI


struct GesturePreference<Value>: Equatable {
    
    static func == (lhs: GesturePreference, rhs: GesturePreference) -> Bool {
        lhs.id == rhs.id && lhs.priority == rhs.priority
    }
    
    let id: UniqueID
    let priority: GesturePriority
    let gesture: AnyGesture<Value>

}

struct GesturePreferenceKey<Value>: PreferenceKey {
    
    static var defaultValue: [GesturePreference<Value>] { [] }
    
    static func reduce(value: inout [GesturePreference<Value>], nextValue: () -> [GesturePreference<Value>]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct WindowGesturePreferenceKey<Value>: PreferenceKey {
    
    static var defaultValue: [GesturePreference<Value>] { [] }
    
    static func reduce(value: inout [GesturePreference<Value>], nextValue: () -> [GesturePreference<Value>]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct GestureHandler<Value> {
    
    @State private var preferences: [GesturePreference<Value>] = []
    
    @MainActor private var gesture: some Gesture {
        preferences.reduce(into: Optional<AnyGesture<Value>>(nil)){ result, partial in
            guard partial.priority != .none else { return }
            
            if result == nil {
                result = partial.gesture
            } else {
                result = AnyGesture(result!.sequenced(before: partial.gesture).map({
                    switch $0 {
                    case let .first(value): return value
                    case let .second(first, _):  return first
                    }
                }))
            }
        }
    }
    
}

extension GestureHandler: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(gesture)
            .onCoordinatedPreference(GesturePreferenceKey.self){ values in
                preferences = values
            }
    }
    
}


struct GestureModifier<Value> {
    
    @State private var id = UniqueID()
    
    let priority: GesturePriority
    let gesture: AnyGesture<Value>
    
}

extension GestureModifier: ViewModifier {
    
    private var value: GesturePreference<Value> {
        .init(
            id: id,
            priority: priority,
            gesture: gesture
        )
    }
    
    func body(content: Content) -> some View {
        content.preference(
            key: GesturePreferenceKey.self,
            value: [value]
        )
    }
    
}


extension View {
    
    nonisolated public func coordinatedGesture<Value>(_ value: Value.Type) -> some View {
        modifier(GestureHandler<Value>())
    }
    
    nonisolated public func preferredGesture(
        priority: GesturePriority = .simultaneous,
        gesture: some Gesture
    ) -> some View {
        modifier(GestureModifier(
            priority: priority,
            gesture: AnyGesture(gesture)
        ))
    }
    
    nonisolated public func gestureCoordinator<Value>(_ value: Value.Type) -> some View {
        preferenceCoordinator(GesturePreferenceKey<Value>.self)
    }
    
}
