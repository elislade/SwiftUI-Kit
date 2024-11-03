import SwiftUI
import SwiftUIKitCore


public struct Radio: View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlSize) private var controlSize
    @Binding var isOn: Bool
    
    private var size: CGFloat {
        switch controlSize {
        case .mini: 20
        case .small: 24
        case .regular: 30
        case .large: 34
        case .extraLarge: 38
        @unknown default: 30
        }
    }
    
    /// Initializes instance
    /// - Parameter isOn: Binding indicating on status.
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    public var body: some View {
        Button(action: { isOn.toggle() }){
            ZStack{
                SunkenControlMaterial(Circle(), isTinted: isOn)
                
                if isOn {
                    RaisedControlMaterial(Circle().inset(by: size / 4))
                        .transition(.scale)
                }
            }
            .contentShape(Circle())
            .frame(width: size, height: size)
            .animation(.bouncy, value: isOn)
        }
        .buttonStyle(.plain)
    }
    
}


public struct RadioToggleStyle: ToggleStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            LabeledContent{ Radio(isOn: configuration.$isOn) } label: { configuration.label }
        } else {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Radio(isOn: configuration.$isOn)
            }
        }
    }
    
}


public extension ToggleStyle where Self == RadioToggleStyle {
    
    static var swiftUIKitRadio: RadioToggleStyle { Self() }
    
}
