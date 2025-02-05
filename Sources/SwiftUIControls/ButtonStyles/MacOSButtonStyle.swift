import SwiftUI
import SwiftUIKitCore

public struct MacOSBasicButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) private var colorScheme
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .padding(.horizontal, 7)
            .background {
                RaisedControlMaterial(
                    RoundedRectangle(cornerRadius: 6),
                    isPressed: configuration.isPressed
                )
            }
    }
    
}


public extension ButtonStyle where Self == MacOSBasicButtonStyle {
    
    static var macOSBasic: MacOSBasicButtonStyle { .init() }
    
}

