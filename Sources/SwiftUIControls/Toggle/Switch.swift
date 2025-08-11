import SwiftUI
import SwiftUIKitCore


/// An improved version of `SwiftUI.Toggle`.
///
/// Benifit of using this explicit Switch over the default switchStyle of Toggle are as follows:
/// - Properly animated values with the current `Transaction` animation. Base `UIKit` bridge does not participate in the `Transaction` animation properly.
/// - Works inside a `DrawingGroup` as it does not bridge to `UIKit` or `AppKit`.
/// - Works with `ControlSize` of environment on all platforms.
/// - Support for ``EnvironmentValues/isOnOffSwitchLabelsEnabled`` EnvironmentValue.
/// - Support for ``EnvironmentValues/controlRadius-property`` modifer.
/// - Support for ``LayoutDirectionSuggestion`` with vertical layouts.
/// - Ability to add custom on/off labels.
public struct Switch<OnLabel: View, OffLabel: View>: View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.controlSize) private var controlSize: ControlSize
    @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
    @Environment(\.isOnOffSwitchLabelsEnabled) private var isOnOffSwitchLabelsEnabled
    @Environment(\.isEnabled) private var isEnabled
    
    @Binding private var isOn: Bool
    private let offLabel: OffLabel
    private let onLabel: OnLabel
    
    @State private var pressing = false
    
    private var layoutVertical: Bool {
        layoutDirectionSuggestion.useVertical
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
    
    private var fixedSize: Double {
        (40 - (20 * interactionGranularity)) * controlFactor
    }
    
    private var labelFont: Font {
        switch controlSize {
        case .mini: return .caption2.weight(.black)
        case .small: return .caption.weight(.heavy)
        case .regular: return .caption.weight(.bold)
        case .large: return .footnote.weight(.semibold)
        case .extraLarge: return .body.weight(.semibold)
        @unknown default: return .caption.weight(.bold)
        }
    }
    
    /// Initializes an instance with both an on and off labels.
    /// - Parameters:
    ///   - isOn: Binding indicating on status.
    ///   - offLabel: A image or view to use as the off label. This will override the `isOnOffSwitchLabelsEnabled` accesibility value when in use.
    ///   - onLabel: A image or view to use as the on label. This will override the `isOnOffSwitchLabelsEnabled` accesibility value when in use.
    public init(
        isOn: Binding<Bool>,
        @ViewBuilder offLabel: () -> OffLabel,
        @ViewBuilder onLabel: () -> OnLabel
    ) {
        self._isOn = isOn.animation(.bouncy)
        self.offLabel = offLabel()
        self.onLabel = onLabel()
    }
    
    private var alignment: Alignment {
        switch layoutDirectionSuggestion {
        case .useSystemDefault: isOn ? .trailing : .leading
        case .useTopToBottom: isOn ? .bottom : .top
        case .useBottomToTop: isOn ? .top : .bottom
        }
    }
    
    @ViewBuilder private var onView: some View {
        if !(onLabel is EmptyView) {
            onLabel
        } else if isOnOffSwitchLabelsEnabled {
            Color.clear.aspectRatio(1, contentMode: .fit).overlay {
                Image(systemName: "poweron")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .font(labelFont)
            }
        }
    }
    
    @ViewBuilder private var offView: some View {
        if !(offLabel is EmptyView) {
            offLabel
        } else if isOnOffSwitchLabelsEnabled {
            Image(systemName: "poweroff")
                .resizable()
                .scaledToFit()
                .opacity(0.3)
                .font(labelFont)
        }
    }
    
    private func content(for shape: some InsettableShape) -> some View {
        ZStack(alignment: alignment){
            SunkenControlMaterial(shape, isTinted: isOn)

            Color.clear
                .overlay(alignment: alignment.inverse){
                    Color.clear
                        .aspectRatio(layoutVertical ? 1.3 : 0.75, contentMode: .fit)
                        .overlay {
                            if isOn {
                                onView.padding(fixedSize / 6)
                            } else {
                                offView.padding(fixedSize / 6)
                            }
                        }
                    }
            
            RaisedControlMaterial(shape.inset(by: 2))
                .blendMode(.hardLight)
                .aspectRatio(pressing ? layoutVertical ? 0.85 : 1.3 : 1, contentMode: .fit)
            
        }
        .aspectRatio(layoutVertical ? 0.59 : 1.7, contentMode: .fit)
        .contentShape(shape)
    }
    
    public var body: some View {
        Button{ isOn.toggle() } label : {
            content(
                for: RoundedRectangle(
                    cornerRadius: (fixedSize / 2.0) * (controlRoundness ?? 1)
                )
            )
        }
        .buttonStyle(.plain)
        .frame(
            width: layoutVertical ? fixedSize : nil,
            height: layoutVertical ? nil : fixedSize
        )
        .fixedSize()
        .animation(.smooth.speed(1.5), value: pressing)
        #if !os(tvOS)
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged{ _ in
                    pressing = true
                }
                .onEnded{ _ in
                    pressing = false
                    isOn.toggle()
                }
        )
        #endif
        .opacity(isEnabled ? 1 : 0.5)
        .sensoryFeedbackPolyfill(.impact(), value: isOn)
    }
    
}

public extension Switch where OnLabel == EmptyView {
    
    /// Initializes instance with an off label
    /// - Parameters:
    ///   - isOn: Binding indicating on status.
    ///   - offLabel: A image or view to use as the off label. This will override the `isOnOffSwitchLabelsEnabled` accesibility value when in use.
    init(isOn: Binding<Bool>, @ViewBuilder offLabel: () -> OffLabel) {
        self.init(isOn: isOn, offLabel: offLabel, onLabel: { EmptyView() })
    }
    
}

public extension Switch where OffLabel == EmptyView {
    
    /// Initializes instance with an on label
    /// - Parameters:
    ///   - isOn: Binding indicating on status.
    ///   - onLabel: A image or view to use as the on label. This will override the `isOnOffSwitchLabelsEnabled` accesibility value when in use.
    init(isOn: Binding<Bool>, @ViewBuilder onLabel: () -> OnLabel) {
        self.init(isOn: isOn, offLabel: { EmptyView() }, onLabel: onLabel)
    }
    
}

public extension Switch where OffLabel == EmptyView, OnLabel == EmptyView {
    
    /// Initializes instance with no on/off labels. This will result in using default I/O labels when ``SwiftUI/EnvironmentValues/isOnOffSwitchLabelsEnabled``
    ///  accesibility is enabled.
    /// - Parameter isOn: Binding indicating on status.
    init(isOn: Binding<Bool>) {
        self.init(isOn: isOn, offLabel: { EmptyView() }, onLabel: { EmptyView() })
    }
    
}


public struct SwitchToggleStyle: ToggleStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            LabeledContent{
                Switch(isOn: configuration.$isOn)
            } label: {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Switch(isOn: configuration.$isOn)
            }
        }
    }
    
}


public extension ToggleStyle where Self == SwitchToggleStyle {
    
    static var swiftUIKitSwitch: SwitchToggleStyle { Self() }
    
}
