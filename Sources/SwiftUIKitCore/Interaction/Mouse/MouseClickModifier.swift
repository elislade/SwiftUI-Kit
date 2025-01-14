import SwiftUI


struct MouseClickModifier: ViewModifier {
    
    @State private var id = UUID()
    @State private var windowRef: OSWindow?
    
    let action: (MouseClickEvent) -> Void
    
    func body(content: Content) -> some View {
        content
            .windowReference{ windowRef = $0 }
            .onHover {
                if $0 {
                    MouseClickEventCoordinator.shared.registerListener(key: id, action, in: windowRef)
                } else {
                    MouseClickEventCoordinator.shared.unregisterListener(key: id)
                }
            }
    }

}
