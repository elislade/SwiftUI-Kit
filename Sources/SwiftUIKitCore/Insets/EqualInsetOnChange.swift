import SwiftUI


struct OnEqualInsetChangeModifier<V: Equatable>: ViewModifier {

    @State private var id = UUID().uuidString
    @State private var value: V?
    
    let transform: (EdgeInsets) -> V
    let action: (V) -> Void
    
    func body(content: Content) -> some View {
        content
            .preference(key: EqualItemInsetPreferenceKey.self, value: [
                .init(id: id, proposal: nil){ value = transform($0) }
            ])
            .onChangePolyfill(of: value){
                if let value {
                    action(value)
                }
            }
    }
    
}
