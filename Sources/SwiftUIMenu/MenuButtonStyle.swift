import SwiftUI
import SwiftUIKitCore

public struct MenuButtonStyle: PrimitiveButtonStyle {
    
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.isEnabled) private var isEnabled
    
    private let dismissOnAction: Bool
    
    @State private var id = UUID()
    @State private var isActive = false
    
    public init(dismissOnAction: Bool = true) {
        self.dismissOnAction = dismissOnAction
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
            .contentShape(Rectangle())
            .accessibilityAction {
                configuration.trigger()
                
                if dismissOnAction {
                    dismiss()
                }
            }
            .foregroundStyle(isActive ? AnyShapeStyle(.background) : AnyShapeStyle(configuration.role == .destructive ? .red : Color.primary))
            .symbolVariant(isActive ? .fill : .none)
            .background{
                Rectangle()
                    .fill(configuration.role == .destructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
                    .opacity(isActive ? 1 : 0)
                    .allowsHitTesting(false)
                
                Rectangle()
                    .fill(.linearGradient(
                        colors: [.black.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .blendMode(.overlay)
                    .opacity(isActive ? 0.6 : 0)
            }
            .opacity(isEnabled ? 1 : 0.5)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: MenuButtonPreferenceKey.self,
                        value: isEnabled ? [
                            .init(
                                id: id,
                                globalRect: proxy.frame(in: .global),
                                dismissOnAction: dismissOnAction,
                                active: { _isActive.wrappedValue = $0 },
                                action: { configuration.trigger() }
                            )
                        ] : []
                    )
                }
                .hidden()
            }
    }
    
    
    struct Style: ButtonStyle {
        
        @Environment(\.isEnabled) private var isEnabled
        
        var isActive: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            let isPressed = isActive || configuration.isPressed
            configuration.label
                .symbolVariant(isActive ? .fill : .none)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .contentShape(Rectangle())
                .foregroundStyle(isPressed ? AnyShapeStyle(.background) : AnyShapeStyle(Color.primary))
                .background{
                    Rectangle()
                        .fill(configuration.role == .destructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
                        .opacity(isPressed ? 1 : 0)
                        .allowsHitTesting(false)
                }
                .opacity(isEnabled ? 1 : 0.5)
        }
        
    }
    
}


public extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    
    var menuStyle: MenuButtonStyle { .init() }
    
}



public enum MenuActionTriggerBehaviour: Hashable, Sendable {
    case immediate
    case afterDismissal
}


public extension View {
    
    func menuActionTriggerBehaviour(_ behaviour: MenuActionTriggerBehaviour) -> some View {
        transformPreference(MenuButtonPreferenceKey.self){ actions in
            for i in actions.indices {
                actions[i].actionBehaviour = behaviour
            }
        }
    }
    
    func menuActionDwellDuration(_ duration: TimeInterval?) -> some View {
        transformPreference(MenuButtonPreferenceKey.self){ actions in
            for i in actions.indices {
                actions[i].dwellDuration = duration
            }
        }
    }
    
}
