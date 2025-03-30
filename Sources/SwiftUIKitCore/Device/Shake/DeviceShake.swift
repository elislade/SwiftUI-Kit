import SwiftUI


public extension View {
    
    #if canImport(UIKit) && !os(watchOS)
    
    /// Gets called whenever the device shakes.
    /// - Parameter onChanged: A callback that gets called whenever the device shakes.
    /// 
    /// - Returns: A view that listens to device shakes.
    func onDeviceShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(onChanged: action))
    }

    #else


    /// Placeholder API for platforms that don't support shake gestures for ease of use at callsites between platforms.
    /// - Parameter onChanged: Will not get called onShake because shake gestures don't exist on this platform.
    /// - Returns: Self as this method does nothing.
    func onDeviceShake(perform action: @escaping () -> Void) -> Self {
        self
    }
    
    #endif
    
}
