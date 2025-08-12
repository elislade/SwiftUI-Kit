#if !os(visionOS)

import SwiftUI


struct OnChangeModifier<Value: Equatable> {

    @State private var lastState: Value?
    
    let value: Value
    let initial: Bool
    let callback: () -> Void
    
    init(value: Value, initial: Bool, callback: @escaping () -> Void) {
        self.value = value
        self.initial = initial
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value){ lastState = $0 }
            .onChange(of: lastState){ s in
                callback()
            }
            .onAppear {
                if initial {
                    lastState = value
                }
            }
    }
 
}

extension OnChangeModifier: ViewModifier {}

#endif
