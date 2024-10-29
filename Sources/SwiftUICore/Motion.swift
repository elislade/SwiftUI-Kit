import SwiftUI
import Combine

#if canImport(UIKit)

enum WindowShake {
    
    static let passthrough = PassthroughSubject<Void, Never>()
    
}

extension UIWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            WindowShake.passthrough.send(())
        }
    }
    
}

struct DeviceShakeViewModifier: ViewModifier {
    
    let onChanged: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(WindowShake.passthrough, perform: onChanged)
    }
    
}

public extension View {
    
    /// Gets called whenever the device shakes.
    /// - Parameter onChanged: A callback that gets called whenever the device shakes.
    /// 
    /// - Returns: A view that listens to device shakes.
    func onShake(perform onChanged: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(onChanged: onChanged))
    }
    
}

#else

public extension View {
    
    /// Placeholder API for platforms that don't support shake gestures for ease of use at callsites between platforms.
    /// - Parameter onChanged: Will not get called onShake because shake gestures don't exist on this platform.
    /// - Returns: Self as this method does nothing.
    func onShake(perform onChanged: @escaping () -> Void) -> Self {
        self
    }
    
}

#endif
