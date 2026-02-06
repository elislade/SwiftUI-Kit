import SwiftUI

extension View {
    
#if os(iOS)
    nonisolated public func deviceOrientationListener() -> some View {
        modifier(DeviceOrientationModifier())
    }
#else
    nonisolated public func deviceOrientationListener() -> Self {
        self
    }
#endif
    
    @available(*, deprecated, renamed: "deviceOrientationListener()")
    nonisolated public func listenForDeviceOrientation() -> some View {
        deviceOrientationListener()
    }
    
}
