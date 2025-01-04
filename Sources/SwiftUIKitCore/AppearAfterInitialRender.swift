import SwiftUI


public struct AppearAfterInitialRender<Content: View>: View {
    
    @State private var show = false
    @ViewBuilder var content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack{
            if show { content }
        }
        .onAppear{
            show = true
        }
    }
    
}
