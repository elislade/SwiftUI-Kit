import SwiftUI


struct OnGeometryChangeOldNewModifier<Value: Equatable>: ViewModifier {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.onGeometryChangesEnabled) private var isEnabled
    
    let transform: (GeometryProxy) -> Value
    let didChange: (_ oldValue: Value, _ newValue: Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .background {
                if isEnabled && frozenState.isThawed {
                    GeometryReader{ proxy in
                        Color.clear.onChangePolyfill(of: transform(proxy), initial: true){ old, new in
                            didChange(old, new)
                        }
                    }
                    .hidden()
                }
            }
    }
    
}
