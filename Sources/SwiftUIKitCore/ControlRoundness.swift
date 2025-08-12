import SwiftUI


public extension EnvironmentValues {
    
    /// An optional Double from `0` to `1` where `1` is the most round and `0` is the least. Default is `nil` which leaves it up to the control to decide.
    @Entry var controlRoundness: Double? = nil
    
}


public extension View {
    
    /// - Parameter roundness: An optional Double from `0` to `1` where `1` is the most round and `0` is the least. Default is `nil` which leaves it up to the control to decide.
    /// - Returns: A view that sets the ``SwiftUI/EnvironmentValues/controlRoundness`` value.
    nonisolated func controlRoundness(_ roundness: Double?) -> some View {
        environment(\.controlRoundness, roundness)
    }
    
}
