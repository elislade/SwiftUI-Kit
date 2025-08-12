#if !os(visionOS)
import SwiftUI


struct OnChangeOldNewModifier<Value: Equatable> {
    
    @State private var oldValue: Value
    
    let value: Value
    let initial: Bool
    let callback: ((Value, Value) -> Void)
    
    init(value: Value, initial: Bool, callback: @escaping (Value, Value) -> Void) {
        self._oldValue = State(initialValue: value)
        self.value = value
        self.initial = initial
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value){ deprecatedValue in
                callback(oldValue, deprecatedValue)
                oldValue = deprecatedValue
            }
            .onAppear {
                if initial {
                    callback(oldValue, value)
                }
            }
    }
 
}

extension OnChangeOldNewModifier: ViewModifier {}

#endif
