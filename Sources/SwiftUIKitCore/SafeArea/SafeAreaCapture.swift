import SwiftUI


public extension View {
    
    nonisolated func captureContainerSafeArea(edges: Edge.Set = .all) -> some View {
        modifier(CaptureContainerInsetModifier(edges: edges))
    }
    
    nonisolated func releaseContainerSafeArea(edges: Edge.Set = .all) -> some View {
        modifier(ReleaseContainerInsetModifier(edges: edges))
    }
    
}


extension EnvironmentValues {
    
    @Entry var capturedContainerInsets = EdgeInsets()
    
}


struct CaptureContainerInsetModifier: ViewModifier {
    
    @State private var keyboardInsets = EdgeInsets()
    
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
        GeometryReader {
            let allInsets = $0.safeAreaInsets
            content
                .ignoresSafeArea(.container, edges: edges)
                .transformEnvironment(\.capturedContainerInsets){ capture in
                    if !edges.isEmpty {
                        // replace the captured edges with edges from the current proxy
                        let nonKeyboardInsets = allInsets.copy(transforming: .all, from: keyboardInsets){ $0 - $1 }
                        capture = capture.copy(
                            replacing: edges,
                            from: nonKeyboardInsets
                        )
                    }
                }
        }
        .onSafeAreaChange(.keyboard){ keyboardInsets = $0 }
    }
    
}



struct ReleaseContainerInsetModifier: ViewModifier {
    
    @Environment(\.capturedContainerInsets) private var capturedInsets
    
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
       content
            .safeAreaInsets(EdgeInsets().copy(replacing: edges, from: capturedInsets))
            .transformEnvironment(\.capturedContainerInsets){ capture in
                // set the edges that were released with 0
                capture = capture.copy(replacing: edges, from: EdgeInsets())
            }
    }
    
}
