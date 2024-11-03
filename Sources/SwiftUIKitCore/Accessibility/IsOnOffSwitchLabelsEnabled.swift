import SwiftUI

struct AccessibilityIsOnOffSwitchLabelsEnabledKey: EnvironmentKey {
    static var defaultValue : Bool = false
}


struct AccessibilityIsOnOffSwitchLabelsModifier: ViewModifier {
    
    @State private var isEnabled: Bool?
    
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.isOnOffSwitchLabelsEnabled){ value in
                if let isEnabled {
                    value = isEnabled
                }
            }
        #if canImport(UIKit)
            .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.onOffSwitchLabelsDidChangeNotification)){ _ in
                isEnabled = UIAccessibility.isOnOffSwitchLabelsEnabled
            }
            .onAppear {
                isEnabled = UIAccessibility.isOnOffSwitchLabelsEnabled
            }
        #endif
    }
    
}


public extension EnvironmentValues {
    
    /// A Bool that indicates whether a `Switch` should show on/off labels. This setting can be set in system Settings under Accessibility or manually set in app with the use of the `environment()` modifier.
    /// - Note: This modifier only works with `SwiftUICore` Switches and any view that is made to take advantage of this value. It will **not** work with `SwiftUI.Toggle` with a `.switchStyle` as it does not support this setting.
    var isOnOffSwitchLabelsEnabled: Bool {
        get { self[AccessibilityIsOnOffSwitchLabelsEnabledKey.self] }
        set { self[AccessibilityIsOnOffSwitchLabelsEnabledKey.self] = newValue }
    }
    
}


public extension View {
    
    /// Listens to changes of `UIAccessibility.isOnOffSwitchLabelsEnabled` and sets an environment value to match.
    /// - Returns: A view that listens to changes of `UIAccessibility.isOnOffSwitchLabelsEnabled` and sets an environment value to match.
    func listenForOnOffSwitchLabelsEnabled() -> some View {
        modifier(AccessibilityIsOnOffSwitchLabelsModifier())
    }
    
}
