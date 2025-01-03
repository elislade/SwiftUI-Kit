import SwiftUI


struct OnGeometryChangePolyfill<Value: Equatable>: ViewModifier {
    
    let transform: (GeometryProxy) -> Value
    let didChange: (Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader{ proxy in
                    let value = transform(proxy)
                    
                    Color.clear.onChangePolyfill(of: value, initial: true){
                        didChange(transform(proxy))
                    }
                }
                .hidden()
            }
    }
    
}


struct OnGeometryChangePolyfillOldNew<Value: Equatable>: ViewModifier {
    
    let transform: (GeometryProxy) -> Value
    let didChange: (_ oldValue: Value, _ newValue: Value) -> ()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader{ proxy in
                    Color.clear.onChangePolyfill(of: transform(proxy), initial: true){ old , new in
                        didChange(old, new)
                    }
                }
                .hidden()
            }
    }
    
}


public extension View {
    
    func onGeometryChangePolyfill<T: Equatable>(
        for type: T.Type = T.self,
        of transform: @escaping (GeometryProxy) -> T,
        action: @escaping (T) -> Void
    ) -> some View {
        modifier(OnGeometryChangePolyfill(transform: transform, didChange: action))
    }
    
    func onGeometryChangePolyfill<T: Equatable>(
        for type: T.Type = T.self,
        of transform: @escaping (GeometryProxy) -> T,
        action: @escaping (_ oldValue: T, _ newValue: T) -> Void
    ) -> some View {
        modifier(OnGeometryChangePolyfillOldNew(transform: transform, didChange: action))
    }
    
}
