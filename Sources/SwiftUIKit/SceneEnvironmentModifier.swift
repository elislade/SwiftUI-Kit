import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct SceneEnvironmentModifier: ViewModifier {
    
    @Environment(\.sceneSize) private var parentSceneSize

    func body(content: Content) -> some View {
        // Don't allow nesting of SceneEnvironmentModifier
        // If parent size is zero we know it hasen't been setup before as this is the default value
        // views can't have zero size
        if parentSceneSize == .zero {
            GeometryReader{ proxy in
                ZStack {
                    Color.clear
                    content
                }
                .presentationContext()
                .anchorPresentationContext()
                .focusPresentationContext()
                .coordinatedWindowEvents()
                .ignoresSafeArea()
                .environment(\.sceneProxy, proxy)
                .environment(\.sceneInsets, proxy.safeAreaInsets)
                .listenForDeviceOrientation()
                .listenForOnOffSwitchLabelsEnabled()
            }
        } else {
            content
        }
    }
    
}


public extension View {
    
    /// A convience for setting many scene level features that SwiftUIKit introduces ontop of SwiftUI. This is intended to only be used once at the root of your view hirarchey. This modifier will have no effect on subsequent uses after the first one.
    /// - Returns: A view that modifies the root view.
    func sceneEnvironment() -> some View {
        modifier(SceneEnvironmentModifier())
    }
    
}
