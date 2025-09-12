import SwiftUI
import SwiftUIKitCore


extension EnvironmentValues {
    
    @Entry internal var menuBackgroundStyle: AnyMaterialStyle?
    
}

public extension View {
    
    //TODO: Depricated use menuBackgroundStyle instead.
    func menuBackground<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Self {
        self
    }
    
    func menuBackgroundStyle(_ style: some MaterialStyle) -> some View {
        environment(\.menuBackgroundStyle, AnyMaterialStyle(style))
    }
    
}


struct MenuBackground: View {
    
    @Environment(\.menuBackgroundStyle) private var backgroundStyle
    @Environment(\.menuVisualDepth) var visualDepth
    
    var body: some View {
        ZStack {
            if let backgroundStyle {
                backgroundStyle.makeBody(ContainerRelativeShape())
            } else {
                ContainerRelativeShape()
                    .fill(.regularMaterial)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 20 * visualDepth,
                        y: 20 * visualDepth
                    )
                    .zIndex(1)
                
                InteractionGlowMaterial(ContainerRelativeShape())
                    .zIndex(2)
                
                EdgeHighlightMaterial(ContainerRelativeShape())
                    .zIndex(3)
            }
        }
        .opacity(visualDepth)
    }
}
