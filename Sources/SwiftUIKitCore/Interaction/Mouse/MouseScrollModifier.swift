import SwiftUI


struct MouseScrollModifier: ViewModifier {
    
    @State private var id = UUID()
    @State private var windowRef: OSWindow?
    
    let action: (MouseScrollEvent) -> Void
    
    func body(content: Content) -> some View {
        content
            .windowReference{ windowRef = $0 }
            .onHover {
                if $0 {
                    MouseScrollEventCoordinator.shared.registerListener(key: id, action, in: windowRef)
                } else {
                    MouseScrollEventCoordinator.shared.unregisterListener(key: id)
                }
            }
    }

}
