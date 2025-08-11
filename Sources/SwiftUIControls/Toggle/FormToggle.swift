import SwiftUI
import SwiftUIKitCore


public struct FormToggle: View {
    
    public enum Exclusivity: Hashable, CaseIterable, Sendable {
        case exclusive
        case nonExclusive
    }
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlSize) private var controlSize: ControlSize
    @Environment(\.controlRoundness) private var roundness: Double?
    
    @Binding private var isOn: Bool
    private let exclusivity: Exclusivity
    
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
    
    private var fixedSize: Double {
        size - (10 * interactionGranularity)
    }
    
    private var shape: some InsettableShape {
        switch exclusivity {
        case .exclusive:
            AnyInsettableShape(Circle())
        case .nonExclusive:
            AnyInsettableShape(RoundedRectangle(
                cornerRadius: (fixedSize / 2.5) * (roundness ?? 0.5)
            ))
        }
    }
    
    /// Initializes instance
    /// - Parameter isOn: Binding indicating on status.
    public init(isOn: Binding<Bool>, exclusivity: Exclusivity) {
        self._isOn = isOn
        self.exclusivity = exclusivity
    }
    
    public var body: some View {
        Button(action: { isOn.toggle() }){
            ZStack{
                SunkenControlMaterial(shape, isTinted: isOn)
                
                if isOn {
                    switch exclusivity {
                    case .exclusive:
                        RaisedControlMaterial(Circle().inset(by: fixedSize / 4))
                            .transition(.scale)
                    case .nonExclusive:
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .padding(fixedSize / 4)
                            .font(.body.weight(.heavy))
                            .foregroundStyle(.white)
                            .transition(.scale)
                    }
                }
            }
            .contentShape(shape)
            .frame(width: fixedSize, height: fixedSize)
            .animation(.bouncy, value: isOn)
        }
        .buttonStyle(.plain)
    }
    
}


public struct FormToggleStyle: ToggleStyle {
    
    let exclusivity: FormToggle.Exclusivity
    
    public func makeBody(configuration: Configuration) -> some View {
        Button{ configuration.isOn.toggle() } label: {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                FormToggle(isOn: configuration.$isOn, exclusivity: exclusivity)
            }
        }
    }
    
}


public extension ToggleStyle where Self == FormToggleStyle {
    
    static func form(_ exclusivity: FormToggle.Exclusivity) -> Self {
        Self(exclusivity: exclusivity)
    }
    
    static var swiftUIKitRadio: Self { .form(.exclusive) }
    static var swiftUIKitCheckbox: Self { .form(.nonExclusive) }
    
}
