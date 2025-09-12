import SwiftUI

// Since SwiftUI made the decision to evaluate SafeArea after geometry effects are applied instead of before,
// when you drag a view around, its safe area will change which is not good.
// Capture/release is to help mitigate this weird decision the SwiftUI team made.
// Any offset or scale effects applied between a capture and release will not continously observe safe area changes.

public extension View {
    
    /// Start capturing SafeArea.
    /// - Note: Any offset or scale effects applied between a capture and release will not continously observe safe area changes.
    /// - Parameter edges: A set of edges to capture. Defaults to all.
    /// - Returns: A modified view.
    nonisolated func captureContainerSafeArea(edges: Edge.Set = .all) -> some View {
        modifier(CaptureContainerInsetModifier(edges: edges))
    }
    
    /// Stop capturing SafeArea.
    /// - Note: Any offset or scale effects applied between a capture and release will not continously observe safe area changes.
    /// - Parameter edges: A set of edges to release from capturing.
    /// - Returns: A modified view.
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
                    guard !edges.isEmpty else { return }
                    
                    // replace the captured edges with edges from the current proxy
                    let nonKeyboardInsets = allInsets.copy(transforming: .all, from: keyboardInsets){ $0 - $1 }
                    capture = capture.copy(
                        replacing: edges,
                        from: nonKeyboardInsets
                    )
                }
        }
        .onSafeAreaChange(.keyboard){
            keyboardInsets = $0
        }
    }
    
}



struct ReleaseContainerInsetModifier: ViewModifier {
    
    @Environment(\.capturedContainerInsets) private var capturedInsets
    
    let edges: Edge.Set
    
    private var insets: EdgeInsets {
        EdgeInsets().copy(replacing: edges, from: capturedInsets)
    }
    
    func body(content: Content) -> some View {
       content
            .safeAreaInsets(insets)
            //.animation(.fastSpringInterpolating, value: insets)
            .transformEnvironment(\.capturedContainerInsets){ capture in
                // set the edges that were released with 0
                capture = capture.copy(replacing: edges, from: EdgeInsets())
            }
    }
    
}
