import SwiftUI


struct HasProgressPreferenceKey: PreferenceKey {
    
    static let defaultValue: [Double] = []
    
    static func reduce(value: inout [Double], nextValue: () -> [Double]) {
        value.append(contentsOf: nextValue())
    }
    
}


public extension View {
    
    /// Takes the total set of available child progress and merges them into one, with average progress for all combined.
    /// - Parameter shouldMerge: Bool of whether to merge or not. Defaults to true.
    /// - Returns: A modified preference.
    nonisolated func mergeHasProgress(_ shouldMerge: Bool = true) -> some View {
        transformPreference(HasProgressPreferenceKey.self){ value in
            if shouldMerge, value.count > 1 {
                value = [Double(value.reduce(0, +)) / Double(value.count)]
            }
        }
    }
    
    nonisolated func hasProgressReset(_ reset: Bool = true) -> some View {
        preferenceKeyReset(HasProgressPreferenceKey.self, reset: reset)
    }
    
    nonisolated func hasProgress(_ progress: Double, enabled: Bool = true) -> some View {
        preference(key: HasProgressPreferenceKey.self, value: enabled ? [progress] : [])
    }
    
    nonisolated func hasProgressChanged(perform action: @escaping ([Double]) -> Void) -> some View {
        onPreferenceChange(HasProgressPreferenceKey.self, perform: action)
    }
    
}
