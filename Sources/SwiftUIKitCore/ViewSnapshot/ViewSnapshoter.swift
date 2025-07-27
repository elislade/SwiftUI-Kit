import SwiftUI


@MainActor struct ViewSnapshoter<V: Equatable, Content: View> {
    
    let content: Content
    let value: V
    let initial: Bool
    let action: @MainActor (AnyView) -> Void
    
    final class Coordinator {
        var lastValue: V?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}


#if os(watchOS)

extension ViewSnapshoter: View {
    
    var body: some View {
        content
            .onChangePolyfill(of: value, initial: initial){
                action(AnyView(content))
            }
    }
    
}

#endif
