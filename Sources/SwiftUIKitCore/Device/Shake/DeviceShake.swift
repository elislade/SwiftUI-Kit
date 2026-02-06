import SwiftUI


extension View {
    
    #if canImport(UIKit) && !os(watchOS)
    
    /// Gets called whenever the device shakes.
    /// - Parameter onChanged: A callback that gets called whenever the device shakes.
    /// 
    /// - Returns: A view that listens to device shakes.
    nonisolated public func onDeviceShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }

    #else


    /// Placeholder API for platforms that don't support shake gestures for ease of use at callsites between platforms.
    /// - Parameter onChanged: Will not get called onShake because shake gestures don't exist on this platform.
    /// - Returns: Self as this method does nothing.
    nonisolated public func onDeviceShake(perform action: @escaping () -> Void) -> Self {
        self
    }
    
    #endif
    
    
    @available(*, deprecated, renamed: "deviceShakeDisabled()")
    nonisolated public func disableDeviceShake(_ disabled: Bool = true) -> some View {
        deviceShakeDisabled(disabled)
    }
    
    nonisolated public func deviceShakeDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.isDeviceShakeEnabled){ isEnabled in
            if disabled {
                isEnabled = false
            }
        }
    }
    
}


extension EnvironmentValues {
    
    @Entry public var isDeviceShakeEnabled: Bool = true
    
}
