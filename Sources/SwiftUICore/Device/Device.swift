import SwiftUI

public extension View {
    
#if os(iOS)
    func listenForDeviceOrientation() -> some View {
        modifier(DeviceOrientationModifier())
    }
#else
    func listenForDeviceOrientation() -> Self {
        self
    }
#endif
    
}
