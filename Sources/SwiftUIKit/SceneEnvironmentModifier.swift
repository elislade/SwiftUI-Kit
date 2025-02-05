import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct SceneEnvironmentModifier: ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.sceneSize) private var parentSceneSize

    @State private var keyboardHeight: Double = 0
    
    private func isTrailingNotch(_ deviceOrientation: DeviceOrientation) -> Bool {
       deviceOrientation == .landscapeTrailing(for: layoutDirection) ? true : false
    }
    
    private func isLeadingNotch(_ deviceOrientation: DeviceOrientation) -> Bool {
        deviceOrientation == .landscapeLeading(for: layoutDirection) ? true : false
    }
    
    func body(content: Content) -> some View {
        // Don't allow nesting of SceneEnvironmentModifier
        // If parent size is zero we know it hasen't been setup before as this is the default value
        // views can't have zero size
        if parentSceneSize == .zero {
            InlineEnvironmentReader(\.deviceOrientation){ orientation in
                GeometryReader{ proxy in
                    var safeArea: EdgeInsets {
                        var area = proxy.safeAreaInsets
                        if keyboardHeight > 0 {
                            area[.bottom] = keyboardHeight
                        }
                        
                        let isLeadingInset = isLeadingNotch(orientation)
                        let isTrailingInset = isTrailingNotch(orientation)
                        
                        // If one side has an inset when in landscape, erase the inset from the opposite edge.
                        // This current implimentation is fragile as it works on the assumptions that there is a notch on one side when landscape orientation is detected that has an safeAreaInset. A device in the future may have no notch obscuring the area, but have an inset. This should not be an issue with iPhone SE in landscape as it should not have horizontal insets from having a square display.
                        // Maybe in the future should add more properties tied to the spcific device on its physical cutouts and compare against that.
                        // An issue with this is that the scene size of a given app space may not be guarenteed to be spanning the full display. And relying on device specifics could lead to false matches.
                        if isLeadingInset || isTrailingInset {
                            if isLeadingInset {
                                area[.trailing] = 0
                            } else {
                                area[.leading] = 0
                            }
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
                    .environment(\.sceneSize, CGSize(
                        width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                        height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                    ))
                    .environment(\.sceneInsets, safeArea)
                }
            }
            .ignoresSafeArea(.keyboard)
            .listenForOnOffSwitchLabelsEnabled()
            #if os(iOS)
            .listenForDeviceOrientation()
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
