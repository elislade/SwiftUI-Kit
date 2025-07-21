import SwiftUI


public extension View {
    
    func maxReadableWidth(_ value: Double) -> some View {
        self
            .frame(maxWidth: value)
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func geometryGroupPolyfill() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            geometryGroup()
        } else {
            self
        }
    }
    
    nonisolated func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
    
    nonisolated func offset(_ simd: SIMD2<Double>) -> some View {
        offset(x: simd.x, y: simd.y)
    }
    
    nonisolated func position(_ simd: SIMD2<Double>) -> some View {
        position(x: simd.x, y: simd.y)
    }
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    nonisolated func language(_ code: Locale.LanguageCode) -> some View {
        environment(\.locale, .init(languageComponents: .init(languageCode: code)))
            .environment(\.layoutDirection, .init(languageCode: code))
    }
    
    
    /// Resets a preference key to it's default value.
    /// - Parameters:
    ///   - key: The Preference key to reset.
    ///   - reset: A Bool indicating whether to reset key  or not. Defaults to true.
    /// - Returns: A modified preference.
    nonisolated func resetPreference<Key: PreferenceKey>(_ key: Key.Type, reset: Bool = true) -> some View {
        transformPreference(Key.self){ value in
            if reset {
                value = Key.defaultValue
            }
        }
    }
    
}
