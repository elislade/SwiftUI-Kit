import SwiftUI
import SwiftUIKitCore


struct PresentationDepthKey: EnvironmentKey {
    
    static var defaultValue: Int { 0 }
    
}


extension EnvironmentValues {
    
    public var presentationDepth: Int {
        get { self[PresentationDepthKey.self] }
        set { self[PresentationDepthKey.self] = newValue }
    }
    
}
