import SwiftUI
import SwiftUIKitCore


public struct TintButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    nonisolated public init(){ }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .foregroundStyle(configuration.role == .destructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
            .saturation(isEnabled ? 1 : 0)
            .opacity(configuration.isPressed || !isEnabled ? 0.5 : 1)
    }
    
}

public extension ButtonStyle where Self == TintButtonStyle {
    
    static nonisolated var tinted: TintButtonStyle { TintButtonStyle() }
    
}
