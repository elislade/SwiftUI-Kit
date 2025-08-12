import SwiftUI

public extension View {
    
#if os(iOS)
    nonisolated func listenForDeviceOrientation() -> some View {
        modifier(DeviceOrientationModifier())
    }
#else
    nonisolated func listenForDeviceOrientation() -> Self {
        self
    }
#endif
    
}
