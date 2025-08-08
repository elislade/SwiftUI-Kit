import SwiftUI


struct ViewSnapshoter<V: Equatable, Content: View> {
    
    let content: Content
    let value: V
    let initial: Bool
    let action: @MainActor (AnyView) -> Void
    
    nonisolated init(content: Content, value: V, initial: Bool, action: @MainActor @escaping (AnyView) -> Void) {
        self.content = content
        self.value = value
        self.initial = initial
        self.action = action
    }
    
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
