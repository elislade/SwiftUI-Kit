import SwiftUI


struct OnGeometryChangeModifier<Value: Equatable>: ViewModifier {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.onGeometryChangesEnabled) private var isEnabled
    
    let transform: (GeometryProxy) -> Value
    let didChange: (Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .background {
                if isEnabled && frozenState.isThawed {
                    GeometryReader{ proxy in
                        let value = transform(proxy)
                        
                        Color.clear.onChangePolyfill(of: value, initial: true){
                            didChange(value)
                        }
                    }
                    .hidden()
                }
            }
    }
    
}
