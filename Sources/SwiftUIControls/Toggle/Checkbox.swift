import SwiftUI
import SwiftUIKitCore


public struct Checkbox: View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.controlSize) private var controlSize: ControlSize
    
    @Binding var isOn: Bool
    
    private var size: Double {
        switch controlSize {
        case .mini: 20
        case .small: 24
        case .regular: 30
        case .large: 34
        case .extraLarge: 38
        @unknown default: 30
        }
    }
    
    
    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: (size / 2.5) * (controlRoundness ?? 0.5))
    }
    
    
    /// Initializes instance
    /// - Parameter isOn: Binding indicating on status.
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    private var foreground: some ShapeStyle {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            AnyShapeStyle(
                .linearGradient(
                    colors: [Color(white: 0.9), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .shadow(.inner(color: .white, radius: 0, y: 1))
                .shadow(.drop(color: .black.opacity(0.2), radius: 2, y: 2))
            )
        } else {
            AnyShapeStyle(.linearGradient(colors: [.white.opacity(0.9), .white], startPoint: .top, endPoint: .bottom))
        }
    }
    
    public var body: some View {
        Button(action: { isOn.toggle() }){
            ZStack{
                SunkenControlMaterial(shape, isTinted: isOn)
                
                if isOn {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .padding(size / 4)
                        .font(.body.weight(.heavy))
                        .foregroundStyle(foreground)
                        .transition(.scale)
                }
            }
            .animation(.bouncy, value: isOn)
            .contentShape(shape)
            .frame(width: size, height: size)
            .animation(nil, value: isOn)
        }
        .buttonStyle(.plain)
    }
    
}


public struct CheckboxToggleStyle: ToggleStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            LabeledContent{ Checkbox(isOn: configuration.$isOn) } label: { configuration.label }
        } else {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Radio(isOn: configuration.$isOn)
            }
        }
    }
    
}


public extension ToggleStyle where Self == CheckboxToggleStyle {
    
    static var swiftUIKitCheckbox: CheckboxToggleStyle { Self() }
    
}
