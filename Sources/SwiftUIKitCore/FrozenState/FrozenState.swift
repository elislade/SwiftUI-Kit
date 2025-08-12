import SwiftUI

/// FrozenState is an experimental way to improve performance by telling other views and modifiers to stop their usual behaviour while remaining in the graph tree in the state you last froze them in.
/// - Note : Should be used if a view is known to become active/thawed again after being disabled/frozen but you don't want to incure the cost of view setup/teardown restoration, like in complicated view hirarchies.
public enum FrozenState: Int, Hashable, Sendable {
    case thawed
    case frozen
    case frozenInvisible
    
    public var isThawed: Bool { self == .thawed }
    public var isFrozen: Bool { self != .thawed }
}


public extension EnvironmentValues {
    
    @Entry var frozenState: FrozenState = .thawed
    
}


public extension View {
    
    nonisolated func frozen(_ newState: FrozenState = .frozen) -> some View {
        modifier(FrozenStateModifier())
            .transformEnvironment(\.frozenState){ state in
                // Only override parent value it's set to default thawed
                if state.isThawed {
                    state = newState
                }
            }
    }
    
}
