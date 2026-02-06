import SwiftUI


extension View {
    
    @available(*, deprecated, renamed: "preferenceKeyReset(_:reset:)")
    nonisolated public func resetPreference<Key: PreferenceKey>(_ key: Key.Type, reset: Bool = true) -> some View {
        preferenceKeyReset(key, reset: reset)
    }
    
    
    /// Resets a preference key to its default value.
    /// - Parameters:
    ///   - key: The `PreferenceKey` to reset.
    ///   - reset: A `Bool` indicating whether to reset key  or not. Defaults to true.
    /// - Returns: A modified view.
    nonisolated public func preferenceKeyReset<Key: PreferenceKey>(_ key: Key.Type, reset: Bool = true) -> some View {
        transformPreference(Key.self){ value in
            if reset {
                value = Key.defaultValue
            }
        }
    }
    
    /// Behaves the same as `onPreferenceChange` but erases preference values to any upstream views, similar to container values.
    nonisolated public func preferenceChangeConsumer<Key: PreferenceKey>(
        _ key: Key.Type = Key.self,
        enabled: Bool = true,
        perform action: @escaping (Key.Value) -> Void
    ) -> some View where Key.Value : Equatable {
        onPreferenceChange(Key.self){ value in
            if enabled { action(value) }
        }
        .preferenceKeyReset(Key.self, reset: enabled)
    }
    
    
    /// Writes every preference values change to the environment.
    /// - Parameters:
    ///   - path: The `EnvironmentValues` path to write to.
    ///   - key: The `PreferenceKey`  type.
    /// - Returns: A modified view.
    nonisolated public func environment<Key: PreferenceKey>(
        _ path: WritableKeyPath<EnvironmentValues, Key.Value>,
        from key: Key.Type
    ) -> some View where Key.Value : Equatable {
        modifier(EnvironmentSetFromPreference<Key>(path: path))
    }
    
}


struct EnvironmentSetFromPreference<Key: PreferenceKey> where Key.Value: Equatable {
    
    let path: WritableKeyPath<EnvironmentValues, Key.Value>
    
    @State private var value: Key.Value = Key.defaultValue
    
}

extension EnvironmentSetFromPreference: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .environment(path, value)
            .preferenceChangeConsumer(Key.self){ value = $0 }
    }
    
}
