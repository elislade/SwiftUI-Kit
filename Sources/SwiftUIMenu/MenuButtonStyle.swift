import SwiftUI
import SwiftUIKitCore

public struct MenuButtonStyle: PrimitiveButtonStyle {
    
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.isEnabled) private var isEnabled
    
    private let hoverTriggerInterval: TimeInterval?
    private let dismissOnAction: Bool
    
    @State private var id = UUID()
    @State private var isActive = false
    
    public init(
        hoverTriggerInterval: TimeInterval? = nil,
        dismissOnAction: Bool = true
    ) {
        self.hoverTriggerInterval = hoverTriggerInterval
        self.dismissOnAction = dismissOnAction
    }
    
//    private func end(_ action: @escaping () -> Void) {
//        isEndingGesture = true
//        triggerTask?.cancel()
//        triggerTask = nil
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//            isEndingGesture = false
//            enteredBoundsGestureTime = nil
//            if dismissOnAction {
//                dismissPresentation()
//            } else {
//                action()
//            }
//        }
//        
//        if dismissOnAction {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
//                action()
//            }
//        }
//    }
    
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
//            .onDisappear {
//                triggerTask?.cancel()
//                triggerTask = nil
//            }
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: MenuButtonPreferenceKey.self,
                        value: isEnabled ? [
                            .init(
                                id: id,
                                globalRect: proxy.frame(in: .global),
                                autoTriggerAfter: hoverTriggerInterval,
                                dismissOnAction: dismissOnAction,
                                active: { isActive = $0 },
                                action: configuration.trigger
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
