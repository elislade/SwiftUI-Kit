import SwiftUI


public extension Scene {
    
    func windowResizabilityMinSize() -> some Scene {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return self.windowResizability(.contentMinSize)
            } else {
                return self
            }
        #else
            self
        #endif
    }
    
    func windowStyleHiddenTitleBarOnMacOS() -> some Scene {
        #if os(macOS)
        self.windowStyle(.hiddenTitleBar)
        #else
        self
        #endif
    }
    
}
