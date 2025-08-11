import SwiftUI
import SwiftUIKitCore


public struct MenuButtonStyle: PrimitiveButtonStyle {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    @Environment(\.actionDwellDuration) private var dwellDuration
    @Environment(\.actionTriggerBehaviour) private var triggerBehaviour
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.isEnabled) private var isEnabled
    
    private let dismissWhenTriggered: Bool
    
    @State private var activatedAt: Date? = nil
    @State private var bounce = false
    @State private var actionShouldTriggerOnDisappear = false
    
    private var isActive: Bool { activatedAt != nil }
    
    public init(dismissWhenTriggered: Bool = true){
        self.dismissWhenTriggered = dismissWhenTriggered
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .symbolEffectBounce(value: bounce, grouping: .byLayer)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
            .contentShape(Rectangle())
            .accessibilityAction {
                configuration.trigger()
                
                if dismissWhenTriggered {
                    dismiss()
                }
            }
            .onChangePolyfill(of: isBeingPresentedOn){
                if isBeingPresentedOn {
                    activatedAt = nil
                }
            }
            .foregroundStyle(isActive ? AnyShapeStyle(.white) : AnyShapeStyle(configuration.role == .destructive ? .red : Color.primary))
            .symbolVariant(isActive ? .fill : .none)
            .background{
                if isActive {
                    ZStack {
                        ContainerRelativeShape()
                            .fill(configuration.role == .destructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
                            .allowsHitTesting(false)
                        
                        ContainerRelativeShape()
                            .fill(.linearGradient(
                                colors: [.black.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .bottom,
                                endPoint: .top
                            ))
                            .blendMode(.overlay)
                            .opacity(0.6)
                        
                        if let dwellDuration  {
                            DwellHighlight(duration: dwellDuration)
                        }
                        
                        EdgeHighlightMaterial(ContainerRelativeShape())
                    }
                    .drawingGroup()
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                    .transition(
                        (.opacity + .blur(radius: 10)).animation(.fastSpringInteractive)
                    )
                }
            }
            .geometryGroupPolyfill()
            .opacity(isEnabled ? 1 : 0.5)
            .task(id: activatedAt){
                guard activatedAt != nil, let dwellDuration else { return }
                if let _ = try? await Task.sleep(nanoseconds: nanoseconds(seconds: dwellDuration)) {
                    configuration.trigger()
                }
            }
            .onDisappear {
                if actionShouldTriggerOnDisappear, triggerBehaviour == .onDisappear {
                    configuration.trigger()
                }
            }
            .onWindowInteractionHover{ phase in
                guard isEnabled else { return }
                
                switch phase {
                case .entered:
                    activatedAt = Date()
                case .left:
                    activatedAt = nil
                case .ended:
                    activatedAt = nil
                    if dismissWhenTriggered {
                        dismiss()
                    }
                    
                    if triggerBehaviour == .immediate {
                        configuration.trigger()
                    } else {
                        actionShouldTriggerOnDisappear = true
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
    
}


public extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    
    static var menu: MenuButtonStyle { .init() }
    
}



public enum ActionTriggerBehaviour: Hashable, Sendable, BitwiseCopyable {
    case immediate
    case onDisappear
}


public extension View {
    
    nonisolated func actionTriggerBehaviour(_ behaviour: ActionTriggerBehaviour) -> some View {
        environment(\.actionTriggerBehaviour, behaviour)
    }
    
    nonisolated func actionDwellDuration(_ duration: TimeInterval?) -> some View {
        environment(\.actionDwellDuration, duration)
    }
    
}


extension EnvironmentValues {
    
    @Entry var actionTriggerBehaviour: ActionTriggerBehaviour = .immediate
    @Entry var actionDwellDuration: TimeInterval? = nil
    
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
