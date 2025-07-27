import SwiftUI


public extension View {
    
    func maskMatching(using namespace: Namespace.ID, enabled: Bool = true) -> some View {
        mask{
            ZStack {
                Rectangle().fill(.white)
                Rectangle()
                    .fill(enabled ? .black : .white)
                    .matchedGeometryEffect(
                        id: "negativeMask",
                        in: namespace,
                        isSource: false
                    )
            }
            .drawingGroup()
            .luminanceToAlpha()
            .ignoresSafeArea()
        }
    }
    
    func maskMatchingSource(using namespace: Namespace.ID, enabled: Bool = true) -> some View {
        background{
            ZStack {
                if enabled {
                    Color.clear.matchedGeometryEffect(
                        id: "negativeMask",
                        in: namespace,
                        isSource: true
                    )
                    .ignoresSafeArea()
                }
            }
            .ignoresSafeArea()
        }
    }
    
}
