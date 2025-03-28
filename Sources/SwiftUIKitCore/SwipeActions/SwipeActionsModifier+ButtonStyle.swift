import SwiftUI


extension SwipeActionsModifier {
    
    
    struct ButtonStyle: PrimitiveButtonStyle {
        
        @State private var isPressed = false
        
        private let didCallAction: () -> Void
        
        init(didCallAction: @escaping () -> Void) {
            self.didCallAction = didCallAction
        }
        
        func makeBody(configuration: Configuration) -> some View {
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
                #if !os(tvOS)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { g  in
                            isPressed = false
                            didCallAction()
                            configuration.trigger()
                        }
                )
                #endif
                .animation(.fastSpringInterpolating, value: isPressed)
                .sensoryFeedbackPolyfill(value: isPressed)
        }
    }
    
    
}
