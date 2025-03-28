import SwiftUI
import SwiftUIKitCore


public enum TextFieldElementVisibility: UInt8, Sendable, Codable, Identifiable, CaseIterable {
    
    public var id: RawValue { rawValue }
    
    case never
    case whileEditing
    case whileNotEditing
    case always
}


public struct TextField<Leading: View>: View {
    
    @Environment(\.font) private var font
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusState
    @Environment(\.controlSize) private var controlSize: ControlSize
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.interactionGranularity) private var interactionGranularity
    
    private let placeholder: LocalizedStringKey
    private let leading: Leading
    
    @Binding var text: String
    private let clearButtonVisibility: TextFieldElementVisibility
    
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        clearButtonVisibility: TextFieldElementVisibility = .always,
        @ViewBuilder leading: @escaping () -> Leading
    ) {
        self.placeholder = titleKey
        self._text = text
        self.clearButtonVisibility = clearButtonVisibility
        self.leading = leading()
    }
    
    private var showLeading: Bool {
        type(of: leading) != EmptyView.self
    }
    
    private var showClearButton: Bool {
        switch clearButtonVisibility {
        case .never: false
        case .always: !text.isEmpty
        case .whileEditing: focusState == true && !text.isEmpty
        case .whileNotEditing: focusState == false && !text.isEmpty
        }
    }
    
    private var controlFactor: Double {
        switch controlSize {
        case .mini: 0.7
        case .small: 0.85
        case .regular: 1
        case .large: 1.2
        case .extraLarge: 1.4
        @unknown default: 1
        }
    }
    
    private var padding: Double {
       (14 - (8 * interactionGranularity)) * controlFactor
    }
    
    private var height: Double {
       (50 - (18 * interactionGranularity)) * controlFactor
    }
    
    private var radius: Double {
        (height / 2) * (controlRoundness ?? 1.0)
    }
    
    public var body: some View {
        SwiftUI.TextField("", text: $text)
            .textFieldStyle(.plain)
            .focused($focusState)
            .overlay(alignment: .leading){
                Text(placeholder)
                    .allowsHitTesting(false)
                    .opacity(text.isEmpty ? 0.5 : 0)
                    .animation(.none, value: text.isEmpty)
                    .animation(.bouncy, value: placeholder)
            }
            .safeAreaInset(edge: .leading, spacing: 0){
                if showLeading {
                    HStack { leading }
                        .padding(padding)
                }
            }
            .safeAreaInset(edge: .trailing, spacing: 0){
                if showClearButton {
                    Button(action: { text = "" }){
                        Label { Text("Clear Field") } icon : {
                            ZStack {
                                Color.clear
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(4)
                                    .frame(maxWidth: 30, maxHeight: 30)
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .buttonStyle(.tintStyle)
                    .symbolRenderingMode(.hierarchical)
                    .labelStyle(.iconOnly)
                    .transitions(.scale, .opacity)
                }
            }
            .padding(.leading, radius / 4)
            .padding(.leading, showLeading ? 0 : padding)
            .frame(height: height)
            .foregroundColor(focusState ? .black : colorScheme == .dark ? .white : .black)
            .background{
                SunkenControlMaterial(RoundedRectangle(cornerRadius: radius), isTinted: focusState)
                RaisedControlMaterial(
                    RoundedRectangle(cornerRadius: radius).inset(by: focusState ? 2 : 0),
                    isPressed: true
                )
                .opacity(focusState ? 1 : 0)
            }
            .contentShape(RoundedRectangle(cornerRadius: radius))
            #if !os(tvOS)
            .onTapGesture { focusState = true }
            #endif
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.fastSpringInterpolating, value: focusState)
            .animation(.bouncy, value: showClearButton)
    }
    
}


public extension TextField where Leading == EmptyView {
    
    init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        clearButtonVisibility: TextFieldElementVisibility = .whileEditing
    ) {
        self.init(titleKey, text: text, clearButtonVisibility: clearButtonVisibility){
            EmptyView()
        }
    }
    
}
