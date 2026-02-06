import SwiftUI
import SwiftUIKitCore


//MARK: - Button

public struct BarButtonStyle: SwiftUI.PrimitiveButtonStyle {
    
    @State private var overscroll: Double = 0
    
    public init(){ }
    
    public func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .buttonStyle(InnerStyle(overscroll: overscroll))
            .onOverscroll{ prog in
                if prog >= 1 {
                    Task {
                        overscroll = 1
                        try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 30)
                        overscroll = 0
                        try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 8)
                        configuration.trigger()
                    }
                } else {
                    overscroll = prog
                }
            }
    }
    
    private struct InnerStyle: SwiftUI.ButtonStyle {
        
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.isInNavBar) private var isInNavBar
        @Environment(\.controlSize) private var controlSize: ControlSize
        @Environment(\.controlRoundness) private var controlRoundness
        @Environment(\.isHighlighted) private var isHighlighted
        @Environment(\.interactionGranularity) private var granularity
        
        @State private var isHovering = false
        private let overscroll: Double
        
        private var fontStyle: Font {
            switch controlSize {
            case .mini: return .caption
            case .small: return .footnote
            case .regular: return .body
            case .large: return .title3.weight(.medium)
            case .extraLarge: return .title2.weight(.medium)
            @unknown default: return .body
            }
        }
        
        private var size: CGFloat {
            switch controlSize {
            case .mini: return 30
            case .small: return 34
            case .regular: return 40
            case .large: return 44
            case .extraLarge: return 48
            @unknown default: return 40
            }
        }
        
        private var interactionSize: CGFloat {
            size + 15 - (30 * granularity)
        }
        
        private var shape: some InsettableShape {
            RoundedRectangle(cornerRadius: (controlRoundness ?? 1) * (size / 2))
        }
        
        init(overscroll: Double = 0){
            self.overscroll = overscroll
        }
        
        func makeBody(configuration: Configuration) -> some View {
            let pressing = configuration.isPressed
            let hasSelection = isHighlighted
            configuration.label
                .symbolEffectBounceIfAvailable(
                    value: isHighlighted || overscroll >= 1,
                    grouping: .byLayer
                )
                .font(fontStyle.weight(.semibold))
                .blendMode(hasSelection ? .destinationOut : .normal)
                .foregroundStyle(.tint)
                .padding(interactionSize / 4)
                .frame(height: interactionSize)
                .frame(minWidth: interactionSize)
                .background(
                    ZStack {
                        if overscroll >= 1 {
                            shape.fill(.tint)
                                .opacity(0.5)
                                .transition(.asymmetric(
                                    insertion: .identity.animation(nil),
                                    removal: (.scale(3) + .opacity).animation(.smooth)
                                ))
                                .zIndex(1)
                        }

                        Rectangle()
                            .fill(.background)
                            .opacity(0.5)
                            .clipShape(shape)
                            .zIndex(2)
                        
                        
                        shape
                            .fill(.tint)
                            .mask {
                                LinearGradient(
                                    colors: [
                                        .black.opacity(hasSelection ? 0.75 : 0.55),
                                        .black.opacity(hasSelection ? 0.55 : 0.45)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .opacity(hasSelection ? 1 : 0.3 + overscroll)
                            }
                            .zIndex(3)
                        
                        EdgeHighlightSmallMaterial(shape)
                            .zIndex(4)
                    }
                    .scaleEffect(pressing ? 1.1 : 1 + (overscroll * 0.2))
                    .animation(.smooth, value: pressing)
                    .animation(.bouncy, value: overscroll)
                )
                .compositingGroup()
                .background {
                    BlurEffectView(blurRadius: 4)
                        .clipShape(shape)
                        .shadow(color: .black.opacity(0.08), radius: 15)
                        .scaleEffect(pressing ? 1.1 : 1 + (overscroll * 0.2))
                }
                .lineLimit(1)
                .contentShape(shape)
                .geometryGroupIfAvailable()
                .opacity(isEnabled ? 1 : 0.4)
                .animation(.smooth, value: hasSelection)
        }
        
        
        struct LabelStyle: SwiftUI.LabelStyle {
            
            func makeBody(configuration: Configuration) -> some View {
                HStack(spacing: 2) {
                    configuration.icon
                        .scaledToFit()
                        .font(.body.weight(.semibold))
                    
                    configuration.title
                }
            }
            
        }
    }
    
    
}



public extension PrimitiveButtonStyle where Self == BarButtonStyle {
    
    static var bar: BarButtonStyle { BarButtonStyle() }
    
}


//MARK: - Toggle


public struct BarToggleStyle: SwiftUI.ToggleStyle {
    
    public init(){}
    
    public func makeBody(configuration: ToggleStyleConfiguration) -> some View {
        Button{ configuration.isOn.toggle() } label: {
            configuration.label
        }
        .isHighlighted(configuration.isOn)
        .buttonStyle(.bar)
    }
    
}


public extension ToggleStyle where Self == BarToggleStyle {
    
    static var bar: BarToggleStyle { BarToggleStyle() }
    
}
