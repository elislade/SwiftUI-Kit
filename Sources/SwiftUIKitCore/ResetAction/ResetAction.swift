import SwiftUI

///
/// A Reset Action is an arbitrary action that can be fired to reset the state of a view.
/// An action is offered as a view preference and is meant to be called by some managing container that wants to reset child state.
///
/// - Note:
/// The view itself decides what a reset means and can be arbitrary but should stick to the concept of resetting state that is not an identity change.
/// Eg. Scrolling a ScrollView to its initial state, popping a navigation stack to its root, etc...
///

public struct AsyncResetAction: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let action: () async -> Void

    public func callAsFunction() async {
        await action()
    }
    
}

public struct ResetActionsKey: PreferenceKey {
    
    public static var defaultValue: [AsyncResetAction] { [] }
    
    public static func reduce(value: inout [AsyncResetAction], nextValue: () -> [AsyncResetAction]) {
        value.append(contentsOf: nextValue())
    }

}

public extension View {
    
    /// Spcifies when to merge reset preferences to the environment
    nonisolated func resetActionContext() -> some View {
        modifier(ResetActionContext())
    }
    
    
    /// Disables all ResetActions from this view downwards from having their preference seen.
    /// 
    /// - Parameter disabled: A boolean indicating whether to disable ResetActions or not.
    /// - Returns: A view that disables child ResetActions.
    nonisolated func resetActionsDisabled(_ disabled: Bool = true) -> some View {
        resetPreference(ResetActionsKey.self, reset: disabled)
    }
    
    
    /// Only the bottom most action is available to call as a preference. So once a view has been reset it should remove its ResetAction preference so views above it can have their ResetAction preference seen.
    /// This means if a view below this view has a preference this views action won't be seen by its parent unless the child removes their preference.
    /// 
    /// - Parameters:
    ///   - active: Bool indicating whether the action is active or not.
    ///   - action : The action that the view wants to be called to reset itself.
    ///
    /// - Returns: A view that set its ResetAction.
    nonisolated func resetAction(active: Bool = true, _ action: @escaping () async -> Void) -> some View {
        background{
            InlineState(UUID()){ id in
                Color.clear.preference(
                    key: ResetActionsKey.self,
                    value: active ? [AsyncResetAction(id: id, action: action)] : []
                )
            }
        }
    }
    
    /// Like reset action but overrides container child actions
    nonisolated func resetActionContainer(active: Bool = true, _ action: @escaping () async -> Void) -> some View {
        InlineState(UUID()){ id in
            transformPreference(ResetActionsKey.self){ actions in
                if active {
                    actions = [ AsyncResetAction(id: id, action: action) ]
                }
            }
        }
    }
    
    
    /// - Parameter closure: A closure that gets called with the bottom most ResetAction available. If no action is available a nil value will be returned.
    /// - Returns: A view that handles child ResetActions.
    nonisolated func resetActionsChanged(_ closure: @escaping ([AsyncResetAction]) -> Void) -> some View {
        onPreferenceChange(ResetActionsKey.self, perform: closure)
    }
    
}
