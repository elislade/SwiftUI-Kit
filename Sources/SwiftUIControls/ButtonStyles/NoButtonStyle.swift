import SwiftUI
import SwiftUIKitCore


public struct NoButtonStyle: ButtonStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
    
}

public extension ButtonStyle where Self == NoButtonStyle {
    
    static var noStyle: NoButtonStyle { NoButtonStyle() }
    
}
