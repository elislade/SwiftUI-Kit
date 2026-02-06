import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct MenuButtonStyle: PrimitiveButtonStyle {
    
    @Namespace private var ns
    
    @Environment(\.isInMenuScroll) private var isInScroll
    @Environment(\.closestPresentationContextNamespace) private var closestNamespace
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    @Environment(\.actionDwellDuration) private var dwellDuration
    @Environment(\.actionTriggerBehaviour) private var triggerBehaviour
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    
    private let dismissWhenTriggered: Bool
    
    @State private var task: Task<Void, Error>?
    @State private var activatedAt: Date? = nil
    @State private var bounce = false
    @State private var actionShouldTriggerOnDisappear = false
    
    private var isActive: Bool { activatedAt != nil }
    private var namespace: Namespace.ID { closestNamespace ?? ns }
    
    public init(dismissWhenTriggered: Bool = true){
        self.dismissWhenTriggered = dismissWhenTriggered
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Group {
           if isInScroll {
                Button{
                    configuration.trigger()
                    if dismissWhenTriggered {
                        dismiss(.context)
                    }
                } label: {
                    configuration.label
                        .modifier(InnerStyle(
                            namespace: namespace,
                            dwellDuration: dwellDuration?.seconds,
                            isActive: isActive
                        ))
                }
                .buttonStyle(.plain)
            } else {
                configuration.label
                    .modifier(InnerStyle(
                        namespace: namespace,
                        dwellDuration: dwellDuration?.seconds,
                        isActive: isActive
                    ))
            }
        }
        .symbolEffectBounce(value: bounce, grouping: .byLayer)
        .accessibilityAction {
            configuration.trigger()
            
            if dismissWhenTriggered {
                dismiss(.context)
            }
        }
        .onChangePolyfill(of: isBeingPresentedOn){
            if isBeingPresentedOn {
                activatedAt = nil
            }
        }
        .background{
            if let dwellDuration, activatedAt != nil {
                Color.clear.task(id: activatedAt, priority: .low){
                    if let _ = try? await Task.sleep(for: dwellDuration) {
                        configuration.trigger()
                    }
                }
            }
        }
        .onDisappear {
            if actionShouldTriggerOnDisappear, triggerBehaviour == .onDisappear {
                configuration.trigger()
            }
        }
        .onInteractionHover{ phase in
            guard isEnabled else { return }

            self.task?.cancel()
            self.task = Task {
                switch phase {
                case .entered: activatedAt = Date()
                case .left: activatedAt = nil
                case .ended:
                    activatedAt = nil
                    
                    switch triggerBehaviour {
                    case .immediate:
                        if dismissWhenTriggered {
                            dismiss(.context)
                            try await Task.sleep(for: .milliseconds(10))
                        }
                        configuration.trigger()
                    case .afterDelay(let delay):
                        if let _ = try? await Task.sleep(for: delay) {
                            if dismissWhenTriggered {
                                dismiss(.context)
                            }
                            configuration.trigger()
                        }
                    case .onDisappear:
                        actionShouldTriggerOnDisappear = true
                        
                        if dismissWhenTriggered {
                            dismiss(.context)
                        }
                    }
                }
            }
        }
        .onHoverPolyfill{ isHovering in
            if isHovering {
                activatedAt = Date()
            } else {
                activatedAt = nil
            }
        }
    }
    
    
    struct InnerStyle: ViewModifier {
        
        @Environment(\.isEnabled) private var isEnabled
        
        let namespace: Namespace.ID
        let dwellDuration: Double?
        let isActive: Bool
        
        func body(content: Content) -> some View {
            content
                .font(.body[.semibold])
                .equalInsetItem()
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .contentShape(ContainerRelativeShape())
                .symbolVariant(isActive ? .fill : .none)
                .background{
                    ZStack {
                        if isActive {
                            ContainerRelativeShape()
                                .fill(.primary)
                                .opacity(0.2)
                                .matchedGeometryEffect(id: "button_bg", in: namespace)

                            if let dwellDuration  {
                                DwellHighlight(duration: dwellDuration)
                            }
                        }
                    }
                    .padding(3)
                    .animation(.fastSpringInterpolating, value: isActive)
                    .allowsHitTesting(false)
                }
                .geometryGroupIfAvailable()
                .opacity(isEnabled ? 1 : 0.5)
                .symbolVariant(isActive ? .fill : .none)
        }
        
    }
    
}


extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    
    public static var menu: Self { .init() }
    
    public static func menu(dismissOnTrigger: Bool = true) -> Self {
        .init(dismissWhenTriggered: dismissOnTrigger)
    }
    
}


extension View {
    
    nonisolated public func actionDwellDuration(_ duration: TimeInterval?) -> some View {
        environment(\.actionDwellDuration, duration == nil ? nil : .seconds(duration!))
    }
    
    nonisolated public func actionDwellDuration(_ duration: Duration?) -> some View {
        environment(\.actionDwellDuration, duration)
    }
    
}


extension EnvironmentValues {
    
    @Entry var actionDwellDuration: Duration? = nil
    
}


struct DwellHighlight: View {
    
    let duration: Double
    @State private var active = false
    
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.1))
            .scaleEffect(
                x: active ? 1 : 0,
                anchor: .leading
            )
            .animation(.linear(duration: duration), value: active)
            .onAppear{ active = true }
            .clipShape(ContainerRelativeShape())
    }
    
}
