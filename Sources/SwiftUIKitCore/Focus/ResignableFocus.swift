import SwiftUI


extension FocusedValues {

    /// A closure to resign child focus.
    /// If nil no children want to be resigned.
    @Entry public var resign: (() -> Void)?
    
}


extension View {
    
    nonisolated public func resignableFocus(_ binding: FocusState<Bool>.Binding) -> some View {
        modifier(ResignableFocusModifier(state: binding))
    }
    
    nonisolated public func resignableFocus<Value: Hashable>(_ binding: FocusState<Value?>.Binding, equals value: Value) -> some View {
        modifier(ResignableFocusOptionalModifier(state: binding, focusedValue: value))
    }
    
}


struct ResignableFocusModifier {
    
    let state: FocusState<Bool>.Binding
    
    init(state: FocusState<Bool>.Binding) {
        self.state = state
    }
    
}


extension ResignableFocusModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .focused(state)
            .focusedValue(\.resign, {
                state.wrappedValue = false
            })
    }
    
}


struct ResignableFocusOptionalModifier<Value: Hashable> {

    let state: FocusState<Value?>.Binding
    let focusedValue: Value
    
    init(state: FocusState<Value?>.Binding, focusedValue: Value) {
        self.state = state
        self.focusedValue = focusedValue
    }
    
}


extension ResignableFocusOptionalModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .focused(state, equals: focusedValue)
            .focusedValue(\.resign, {
                state.wrappedValue = nil
            })
    }
    
}
