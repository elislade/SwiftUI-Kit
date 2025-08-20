import SwiftUI



public extension View {
    
    /// Attemps to capture a snapshot of the current view every time the value changes.
    /// - NOTE: Capture rate may be ratelimited. The action may not be called for every value change.
    /// - Parameters:
    ///   - value: An equatable value to use for deciding when to capture.
    ///   - initial: Bool declaring whether to capture image on first value pass with no changes. Defaults to true.
    ///   - action: A closure that gets called with the Image that was captured.
    /// - Returns: A Modified view
    nonisolated func viewSnapshot<V: Equatable>(
        for value: V,
        initial: Bool = true,
        perform action: @MainActor @escaping (AnyView) -> Void
    ) -> some View {
        ViewSnapshoter(
            content: self.environment(\.isSnapshot, true),
            value: value,
            initial: initial,
            action: action
        )
    }
    
}


extension EnvironmentValues {
    
    @Entry public internal(set) var isSnapshot: Bool = false
    
}
