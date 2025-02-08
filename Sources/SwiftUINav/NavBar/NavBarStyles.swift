import SwiftUI
import SwiftUIKitCore


//MARK: - Button

public struct NavBarButtonStyle: SwiftUI.ButtonStyle {
    
    @Environment(\.isInNavBar) private var isInNavBar
    @Environment(\.controlSize) private var controlSize
    @Environment(\.controlRoundness) private var controlRoundness
    @State private var isHovering = false
    
    private var size: CGFloat {
        switch controlSize {
        case .mini: return 26
        case .small: return 30
        case .regular: return 36
        case .large: return 40
        case .extraLarge: return 46
        @unknown default: return 36
        }
    }
    
    private let isSelected: Bool
    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: (controlRoundness ?? 1) * (size / 2))
    }
    
    public init(isSelected: Bool = false){
        self.isSelected = isSelected
    }
    
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        let hasSelection = configuration.isPressed || isSelected
        configuration.label
            .foregroundStyle(.tint)
            .opacity(hasSelection ? 0 : 1)
            .padding(size / 4)
            .frame(height: size)
            .frame(minWidth: size)
            .background(
                ZStack {
                    Rectangle()
                        .fill(.tint)
                        .opacity(0.08)
                        .zIndex(1)
                    
                    shape
                        .scale(y: hasSelection ? 1 : 0, anchor: .top)
                        .fill(.tint)
                        .mask {
                            LinearGradient(
                                colors: [.black.opacity(0.6), .black.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .opacity(hasSelection ? 1 : 0)
                        .zIndex(2)
                    
                    shape
                        .strokeBorder(.tint)
                        .mask {
                            LinearGradient(
                                colors: [.black, .black.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .opacity(hasSelection ? 1 : 0)
                    
                    shape
                        .strokeBorder(configuration.isPressed ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary), lineWidth: 0.5)
                        .opacity(0.1)
                        .zIndex(3)
                }
                .mask {
                    ZStack {
                        Color.white
                        
                        configuration.label
                            .foregroundStyle(.black)
                            .padding(size / 4)
                    }
                    .drawingGroup()
                    .luminanceToAlpha()
                }
                .clipShape(shape)
            )
            .font(.body.bold())
            .lineLimit(1)
            .contentShape(shape)
            .animation(.fastSpringInterpolating, value: configuration.isPressed)
            .animation(.fastSpringInterpolating, value: isSelected)
            .geometryGroupPolyfill()
    }
    
    
    struct LabelStyle: SwiftUI.LabelStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 2) {
                configuration.icon
                    .scaledToFit()
                    .font(.body.weight(.semibold))
                    .background(Color.green)
                
                configuration.title
            }
        }
        
    }
    
}


public extension ButtonStyle where Self == NavBarButtonStyle {
    
    static var navBarStyle: NavBarButtonStyle { NavBarButtonStyle() }
    
}


//MARK: - Toggle


public struct NavBarToggleStyle: SwiftUI.ToggleStyle {
    
    public init(){}
    
    public func makeBody(configuration: ToggleStyleConfiguration) -> some View {
        Button(action: { configuration.isOn.toggle() }){
            configuration.label
        }
        .buttonStyle(NavBarButtonStyle(isSelected: configuration.isOn))
    }
    
}


public extension ToggleStyle where Self == NavBarToggleStyle {
    
    static var navBarStyle: NavBarToggleStyle { NavBarToggleStyle() }
    
}
