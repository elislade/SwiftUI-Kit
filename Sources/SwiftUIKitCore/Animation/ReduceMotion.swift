import SwiftUI

struct ReduceMotionKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}


public extension EnvironmentValues {
    
    /// A Bool indicating if the environment wants reduced motion. This can be either `accessibilityReduceMotion` from the system or an explicitly set `reduceMotion` value.
    var reduceMotion: Bool {
        get { accessibilityReduceMotion || self[ReduceMotionKey.self] }
        set { self[ReduceMotionKey.self] = newValue }
    }
    
}


public extension View {
    
    /// Sets `reduceMotion` value. If false it will inherit its parent reduce motion value. To override parent value use `environment(\.reduceMotion)` modifier.
    /// - Parameter enabled: A Bool indicating whether reduce motion value is set or not.
    /// - Returns: A view that transforms reduce motion value.
    nonisolated func reduceMotion(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.reduceMotion) { value in
            if enabled {
                value = true
            }
        }
    }
    
}
