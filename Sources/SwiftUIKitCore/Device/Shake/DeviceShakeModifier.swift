#if canImport(UIKit) && !os(watchOS)

import SwiftUI
import Combine

enum WindowShake {
    
    @MainActor static let passthrough = PassthroughSubject<Void, Never>()
    
}

extension UIWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            WindowShake.passthrough.send(())
        }
    }
    
}

struct DeviceShakeViewModifier {
    
    @Environment(\.isDeviceShakeEnabled) private var isEnabled
    let action: () -> Void
    
}

extension DeviceShakeViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isEnabled {
                    Color.clear.onReceive(WindowShake.passthrough, perform: action)
                }
            }
    }
    
}

#endif
