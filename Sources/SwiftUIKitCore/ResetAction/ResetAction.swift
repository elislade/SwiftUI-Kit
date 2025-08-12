import SwiftUI

///
/// A Reset Action is an arbitrary action that can be fired to reset the state of a view.
/// An action is offered as a view preference and is meant to be called by some managing container that wants to reset child state.
///
/// - Note: Only the bottom most action is available to call as a preference. So once a view has been reset it should remove its ResetAction preference, so views above it in the hirarchy can have their preference seen.
/// The view itself decides what a reset means and can be arbitrary but should stick to the concept of resetting state that is not an identity change.
/// Eg. Scrolling a ScrollView to its initial state, popping a navigation stack to its root, etc...
///
public struct ResetAction: Equatable, Sendable {
    
    public static func == (lhs: ResetAction, rhs: ResetAction) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let action: @MainActor () -> Void

    @MainActor public func callAsFunction() {
        action()
    }
    
}


public struct ResetActionKey: PreferenceKey {
    
    public static var defaultValue: ResetAction? { nil }
    
    public static func reduce(value: inout ResetAction?, nextValue: () -> ResetAction?) {
        let next = nextValue()
        if next != nil {
            value = next
        }
    }

}

public extension View {
    
    /// Spcifies when to merge reset preferences to the environment
    nonisolated func resetContext() -> some View {
        modifier(ResetActionContext())
    }
    
    
    /// Disables all ResetActions from this view downwards from having their preference seen.
    /// 
    /// - Parameter disabled: A boolean indicating whether to disable ResetActions or not.
    /// - Returns: A view that disables child ResetActions.
    nonisolated func disableResetAction(_ disabled: Bool = true) -> some View {
        transformPreference(ResetActionKey.self){ action in
            if disabled {
                action = nil
            }
        }
    }
    
    
    /// Only the bottom most action is available to call as a preference. So once a view has been reset it should remove its ResetAction preference so views above it can have their ResetAction preference seen.
    /// This means if a view below this view has a preference this views action won't be seen by its parent unless the child removes their preference.
    /// 
    /// - Parameters:
    ///   - active: Bool indicating whether the action is active or not.
    ///   - action : The action that the view wants to be called to reset itself.
    ///
    /// - Returns: A view that set its ResetAction.
    nonisolated func resetAction(active: Bool = true, _ action: @escaping @MainActor() -> Void) -> some View {
        modifier(ResetActionModifier(active: active, action: action))
    }
    
    
    /// - Parameter closure: A closure that gets called with the bottom most ResetAction available. If no action is available a nil value will be returned.
    /// - Returns: A view that handles child ResetActions.
    nonisolated func childResetAction(_ closure: @escaping (ResetAction?) -> Void) -> some View {
        onPreferenceChange(ResetActionKey.self, perform: closure)
    }
    
}
