import SwiftUI


public struct AppearAfterInitialRender<Content: View>: View {
    
    @State private var show = false
    @ViewBuilder var content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        if show { content } else {
            Color.clear
                .frame(width: 1, height: 1)
                .onAppear{ show = true }
        }
    }
    
}
