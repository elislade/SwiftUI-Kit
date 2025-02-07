import SwiftUI


struct OnGeometryChangeOldNewModifier<Value: Equatable>: ViewModifier {
    
    @Environment(\.onGeometryChangesEnabled) private var isEnabled
    
    let transform: (GeometryProxy) -> Value
    let didChange: (_ oldValue: Value, _ newValue: Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isEnabled {
                    GeometryReader{ proxy in
                        Color.clear.onChangePolyfill(of: transform(proxy), initial: true){ old , new in
                            didChange(old, new)
                        }
                    }
                    .hidden()
                }
            }
    }
    
}
