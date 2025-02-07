import SwiftUI


struct OnGeometryChangeModifier<Value: Equatable>: ViewModifier {
    
    @Environment(\.onGeometryChangesEnabled) private var isEnabled
    
    let transform: (GeometryProxy) -> Value
    let didChange: (Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isEnabled {
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
