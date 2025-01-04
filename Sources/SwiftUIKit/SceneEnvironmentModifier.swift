import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct SceneEnvironmentModifier: ViewModifier {
    
    @Environment(\.sceneSize) private var parentSceneSize

    @State private var keyboardHeight: Double = 0
    
    func body(content: Content) -> some View {
        // Don't allow nesting of SceneEnvironmentModifier
        // If parent size is zero we know it hasen't been setup before as this is the default value
        // views can't have zero size
        if parentSceneSize == .zero {
            GeometryReader{ proxy in
                var safeArea: EdgeInsets {
                    var area = proxy.safeAreaInsets
                    if keyboardHeight > 0 {
                        area[.bottom] = keyboardHeight
                    }
                    return area
                }
                
                ZStack {
                    Color.clear
                    content
                }
                .presentationContext()
                .anchorPresentationContext()
                .focusPresentationContext()
                .ignoresSafeArea()
                .environment(\.sceneProxy, proxy)
                .environment(\.sceneInsets, safeArea)
                .listenForDeviceOrientation()
                .listenForOnOffSwitchLabelsEnabled()
            }
            .ignoresSafeArea(.keyboard)
            #if os(iOS)
            .animation(.fastSpringInterpolating, value: keyboardHeight)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification)){ notification in
                if let frame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                    keyboardHeight = frame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)){ notification in
                keyboardHeight = 0
            }
            #endif
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
