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
                Circle()
                    .fill(.tint)
                    .grayscale(windowIsKey ? 0 : 1)
                    .opacity(windowIsKey ? 1 : 0.5)
                
                Circle().fill(.linearGradient(
                    colors: [.white.opacity(0.5), .clear],
                    startPoint: .top, endPoint: .bottom
                ))
                .blendMode(.overlay)
                
                Circle()
                    .fill(Color.black)
                    .opacity(configuration.isPressed ? 0.3 : 0)
            }
            .onHoverPolyfill{ hovering = $0 }
            .overlay {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 0.5)
                    .opacity(0.3)
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
            .foregroundStyle(Color.primary.opacity(opacity))
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

public extension EnvironmentValues {
    
    @Entry var isHighlighted: Bool = false
    
}


public extension View {
    
    nonisolated func isHighlighted(_ highlighted: Bool = true) -> some View {
        environment(\.isHighlighted, highlighted)
    }
    
}
