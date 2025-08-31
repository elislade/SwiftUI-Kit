import SwiftUI


extension SwipeActionsModifier {
    
    struct SwipeButtonStyle: PrimitiveButtonStyle {
   
        private let didCallAction: () -> Void
        
        init(didCallAction: @escaping () -> Void) {
            self.didCallAction = didCallAction
        }
        
        func makeBody(configuration: Configuration) -> some View {
            Button(role: configuration.role){
                Task {
                    configuration.trigger()
                    didCallAction()
                }
            } label: {
                configuration.label
            }
            .buttonStyle(InnerStyle())
        }
        
        
        struct InnerStyle: ButtonStyle {
            
            func makeBody(configuration: Configuration) -> some View {
                let isPressed = configuration.isPressed
                configuration.label
                    .imageScale(.large)
                    .fixedSize()
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxHeight: .infinity)
                    .background {
                        if let role = configuration.role, role == .destructive {
                            Rectangle().fill(.red).zIndex(1)
                        } else {
                            Rectangle().fill(.tint).zIndex(1)
                        }
                        
                        Rectangle()
                            .fill(.linearGradient(
                                colors: [.black.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .blendMode(.overlay)
                            .zIndex(2)
                        
                        Rectangle()
                            .fill(.black)
                            .opacity(isPressed ? 0.3 : 0)
                            .zIndex(3)
                    }
                    .animation(.fastSpringInterpolating, value: isPressed)
                    .sensoryFeedbackPolyfill(value: isPressed)
            }
        }
        
    }
    
}
