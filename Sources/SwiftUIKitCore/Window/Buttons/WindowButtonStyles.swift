import SwiftUI


public struct WindowMainButtonStyle: ButtonStyle {
    
    @Environment(\.windowIsKey) private var windowIsKey
    @Environment(\.isHighlighted) private var highlighted
    @State private var hovering = false
    
    private var opacity: Double {
        highlighted || hovering ? 0.5 : 0
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 7).weight(.heavy))
            .foregroundStyle(Color.black.opacity(opacity))
            .frame(width: 14, height: 14)
            .background{
                Circle().fill(.tint)
                
                Circle().fill(.linearGradient(
                    colors: [.white.opacity(0.5), .clear],
                    startPoint: .top, endPoint: .bottom
                ))
                .blendMode(.overlay)
                
                Circle()
                    .opacity(configuration.isPressed ? 0.3 : 0)
            }
            .onHover{ hovering = $0 }
            .overlay {
                Circle()
                    .strokeBorder()
                    .opacity(0.12)
            }
    }
    
}


public extension ButtonStyle where Self == WindowMainButtonStyle {
    
    static var windowMain: Self { WindowMainButtonStyle() }
    
}


public struct WindowPanelButtonStyle: ButtonStyle {
    
    private var opacity: Double { 0.5 }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 7).weight(.heavy))
            .foregroundStyle(Color.black.opacity(opacity))
            .frame(width: 14, height: 14)
            .background{
                Circle()
                    .opacity(configuration.isPressed ? 0.3 : 0.1)
            }
    }
    
}


public extension ButtonStyle where Self == WindowPanelButtonStyle {
    
    static var windowPanel: Self { WindowPanelButtonStyle() }
    
}


struct IsHighlightedKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


public extension EnvironmentValues {
    
    var isHighlighted: Bool {
        get { self[IsHighlightedKey.self] }
        set { self[IsHighlightedKey.self] = newValue }
    }
    
}


public extension View {
    
    @inlinable nonisolated func isHighlighted(_ highlighted: Bool = true) -> some View {
        environment(\.isHighlighted, highlighted)
    }
    
}
