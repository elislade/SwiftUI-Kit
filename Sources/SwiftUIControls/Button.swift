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


public struct TintButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .foregroundStyle(configuration.role == .destructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
            .saturation(isEnabled ? 1 : 0)
            .opacity(configuration.isPressed || !isEnabled ? 0.5 : 1)
    }
    
}

public extension ButtonStyle where Self == TintButtonStyle {
    static var tintStyle: TintButtonStyle { TintButtonStyle() }
}


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
