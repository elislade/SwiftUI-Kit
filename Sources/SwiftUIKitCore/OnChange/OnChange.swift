import SwiftUI


extension View {
    
    #if !os(visionOS)
    
    @_disfavoredOverload
    nonisolated public func onChange<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping () -> Void) -> some View {
        modifier(OnChangeModifier(
            value: value,
            initial: initial,
            callback: action
        ))
    }
    
    @_disfavoredOverload
    nonisolated public func onChange<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View {
        modifier(OnChangeOldNewModifier(value: value, initial: initial, callback: action))
    }

    #endif
    
}
