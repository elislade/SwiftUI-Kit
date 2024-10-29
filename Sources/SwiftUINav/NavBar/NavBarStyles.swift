import SwiftUI
import SwiftUICore


//MARK: - Button

public struct NavBarButtonStyle: SwiftUI.ButtonStyle {
    
    @Environment(\.isInNavBar) private var isInNavBar
    //@Environment(\.font) private var font: FontProperties
    @Environment(\.controlSize) private var controlSize
    
    private var size: CGFloat {
        switch controlSize {
        case .mini: return 26
        case .small: return 30
        case .regular: return 36
        case .large: return 40
        case .extraLarge: return 46
        @unknown default: return 34
        }
    }
    
    private var minSize: CGFloat {
        size
//        #if os(iOS)
//        38
//        #else
//        30
//        #endif
    }
    
    private let isSelected: Bool
    private var shape: some InsettableShape { Capsule(style: .circular) }
    
    public init(isSelected: Bool = false){
        self.isSelected = isSelected
    }
    
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .foregroundStyle(
                configuration.isPressed ? AnyShapeStyle(.primary) : AnyShapeStyle(.tint)
            )
            //.font(font[size / 2.3][isSelected ? .bold : .medium])
            .frame(height: size)
            .padding(.horizontal, minSize / 4)
            .frame(minWidth: minSize - (minSize / 2))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .background(
                ZStack {
                    shape
                        .fill(.tint)
                        .opacity(isSelected ? 0.2 : 0.08)
                    
                    shape
                        .strokeBorder(configuration.isPressed ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary), lineWidth: 0.5)
                        .opacity(0.1)
                }
            )
            .contentShape(shape)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.fastSpringInterpolating, value: configuration.isPressed)
            .hoverEffectLift()
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
        //.hoverEffectLift()
    }
    
}


public extension ToggleStyle where Self == NavBarToggleStyle {
    
    static var navBarStyle: NavBarToggleStyle { NavBarToggleStyle() }
    
}


#Preview {
    VStack {
        ForEach(ControlSize.allCases, id: \.hashValue){
            HStack {
                Button("Item A", action: {})
                
                Button(action: {}){
                    Image(systemName: "arrow.left")
                }
                
                InlineBinding(true){ b in
                    Toggle(isOn: b){
                        Text(b.wrappedValue ? "ON" : "OFF")
                            .contentTransitionNumericText()
                    }
                }
                
                InlineBinding(false){
                    Toggle(isOn: $0){
                        Label("Alpha", systemImage: "a.circle")
                    }
                }
                
            }
            .environment(\.controlSize, $0)
        }
    }
    .buttonStyle(.navBarStyle)
    .toggleStyle(.navBarStyle)
    .tint(.pink)
}
