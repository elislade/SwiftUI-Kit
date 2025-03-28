
#if !os(watchOS)

import SwiftUI
import Combine


public extension View {
    
    func onWindowGeometryChange<V: Equatable>(
        type: V.Type = V.self,
        transform: @escaping(CGRect) -> V,
        perform action: @escaping(V) -> Void
    ) -> some View {
        modifier(WindowGeometryModifier(transform: transform, action: action))
    }
    
}


struct WindowGeometryModifier<V: Equatable>: ViewModifier {
    
    let transform: (CGRect) -> V
    let action: (V) -> Void
    
    @State private var publisher: AnyPublisher<V, Never>?
    
    func body(content: Content) -> some View {
        content.windowReference {
            publisher = $0.publisher(for: \.frame)
                .map{ transform($0) }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }
        .overlay {
            if let publisher {
                Color.clear.onReceive(publisher) {
                    action($0)
                }
            }
        }
    }
    
}

#endif
