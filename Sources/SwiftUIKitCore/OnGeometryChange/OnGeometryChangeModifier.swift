import SwiftUI


struct OnGeometryChangeModifier<Value: Equatable> {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.onGeometryChangesEnabled) private var isEnabled
    
    let transform: (GeometryProxy) -> Value
    let didChange: (Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if isEnabled && frozenState.isThawed {
                        GeometryReader{ proxy in
                            let value = transform(proxy)
                            
                            Color.clear.onChange(of: value, initial: true){
                                didChange(value)
                            }
                        }
                        .hidden()
                    }
                }
                .animationDisabled()
            }
    }
    
}

extension OnGeometryChangeModifier: ViewModifier {}
