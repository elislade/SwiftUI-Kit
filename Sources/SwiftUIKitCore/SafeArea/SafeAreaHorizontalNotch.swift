import SwiftUI


struct SafeAreaHorizontalNotchModifier: ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.deviceOrientation) private var orientation
    
    private var edges: Edge.Set {
        switch orientation {
        case .landscapeLeading(for: layoutDirection): .trailing
        case .landscapeTrailing(for: layoutDirection): .leading
        default: []
        }
    }
    
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(edges: edges)
    }
    
}
