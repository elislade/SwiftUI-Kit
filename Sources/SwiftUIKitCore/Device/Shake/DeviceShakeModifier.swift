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

struct DeviceShakeViewModifier: ViewModifier {
    
    let onChanged: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(WindowShake.passthrough, perform: onChanged)
    }
    
}

#endif
