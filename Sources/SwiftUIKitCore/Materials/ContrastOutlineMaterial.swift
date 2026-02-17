import SwiftUI


public struct ContrastOutlineMaterialStyle : MaterialStyle {
    
    public func makeBody(shape: AnyInsettableShape) -> some View {
        InlineEnvironmentValue(\.colorSchemeContrast){ contrast in
            InlineEnvironmentValue(\.colorScheme){ scheme in
                ZStack {
                    let isDark = scheme == .dark, faded = contrast == .standard ? 0.2 : 0.6
                    shape
                        .strokeBorder(.black.opacity(isDark ? 1 : faded), lineWidth: 1)
                    
                    shape
                        .inset(by: 1)
                        .strokeBorder(.white.opacity(isDark ? faded : 1), lineWidth: 1)
                }
            }
        }
    }
    
}


extension MaterialStyle where Self == ContrastOutlineMaterialStyle {
    
    public static var contrastOutline: Self { .init() }
    
}
