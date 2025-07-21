import SwiftUI
import SwiftUIKitCore


public struct NoButtonStyle: ButtonStyle {
    
    nonisolated init(){ }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
    
}

public extension ButtonStyle where Self == NoButtonStyle {
    
    static nonisolated var none: NoButtonStyle { NoButtonStyle() }
    
}
