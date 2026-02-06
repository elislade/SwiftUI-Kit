import SwiftUI


extension SwipeActionsModifier {
    
    struct SwipeButtonStyle: PrimitiveButtonStyle {
   
        @Environment(\.actionTriggerBehaviour) private var triggerBehaviour
        @State private var isHovering: Bool = false
        @State private var performOnDisappear: Bool = false
        
        private let didCallAction: () -> Void
        
        init(didCallAction: @escaping () -> Void) {
            self.didCallAction = didCallAction
        }
        
        func makeBody(configuration: Configuration) -> some View {
            let call: () -> Void = {
                switch triggerBehaviour {
                case .immediate:
                    Task {
                        configuration.trigger()
                        didCallAction()
                    }
                case .onDisappear:
                    performOnDisappear = true
                    didCallAction()
                case .afterDelay(let duration):
                    Task {
                        didCallAction()
                        try? await Task.sleep(for: duration)
                        configuration.trigger()
                    }
                }
            }
            Button(role: configuration.role){
                call()
            } label: {
                configuration.label
            }
            .buttonStyle(InnerStyle(isHovering: isHovering))
            .onInteractionHover{ phase in
                isHovering = phase == .entered
                
                if phase == .ended {
                    call()
                }
            }
            .onDisappear{
                if performOnDisappear {
                    configuration.trigger()
                }
            }
        }
        
        
        struct InnerStyle: ButtonStyle {

            let isHovering: Bool
            
            func makeBody(configuration: Configuration) -> some View {
                let isPressed = configuration.isPressed || isHovering
                configuration.label
                    .symbolEffectBounceIfAvailable(value: isPressed)
                    .foregroundStyle(Color.white)
                    .padding(12)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity)
                    .background {
                        if let role = configuration.role, role == .destructive {
                            ContainerRelativeShape().fill(.red).zIndex(1)
                        } else {
                            ContainerRelativeShape().fill(.tint).zIndex(1)
                        }
                        
                        ContainerRelativeShape()
                            .fill(.linearGradient(
                                colors: [.black.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .blendMode(.overlay)
                            .zIndex(2)
                        
                        ContainerRelativeShape()
                            .fill(.black)
                            .opacity(isPressed ? 0.3 : 0)
                            .zIndex(3)
                    }
                    .drawingGroup()
                    .animation(.fastSpringInterpolating, value: isPressed)
                    .sensoryFeedbackPolyfill(value: isPressed)
            }
        }
        
    }
    
}
