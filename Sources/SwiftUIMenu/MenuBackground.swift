import SwiftUI
import SwiftUIKitCore


extension EnvironmentValues {
    
    @Entry internal var menuBackgroundStyle: AnyMaterialStyle?
    
}

extension View {
    
    nonisolated public func menuBackgroundStyle(_ style: some MaterialStyle) -> some View {
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
//                VisualEffectView()
//                    .clipShape( ContainerRelativeShape())
                ContainerRelativeShape()
                    .fill(.regularMaterial)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 20 * visualDepth,
                        y: 20 * visualDepth
                    )
//                OuterShadowMaterial(
//                    ContainerRelativeShape(),
//                    fill: .black.opacity(0.2),
//                    radius: 20 * visualDepth,
//                    y: 20 * visualDepth
//                )

                InteractionGlowMaterial(ContainerRelativeShape())
                    .zIndex(2)
                    //.blendMode(.overlay)
                
                EdgeHighlightMaterial(ContainerRelativeShape())
                    .zIndex(3)
                    .blendMode(.overlay)
                
                EdgeHighlightMaterial(ContainerRelativeShape())
                    .zIndex(3)
                    .blendMode(.overlay)
            }
        }
        .opacity(visualDepth)
    }
}
