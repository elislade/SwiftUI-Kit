import SwiftUI


public struct InsetReader<Content: View>: View {
    
    @Environment(\.sceneInsets) private var sceneInsets
    @Environment(\.sceneSize) private var sceneSize
    
    private let content: (EdgeInsets) -> Content
    
    public init(_ content: @escaping (EdgeInsets) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            
            content(EdgeInsets(
                top: frame.minY <= sceneInsets.top ? sceneInsets.top : 0,
                leading: frame.minX <= sceneInsets.leading ? sceneInsets.leading : 0,
                bottom: frame.maxY >= sceneSize.height - sceneInsets.bottom ? sceneInsets.bottom : 0,
                trailing: frame.maxX >= sceneSize.width - sceneInsets.trailing ? sceneInsets.trailing : 0
            ))
        }
    }
    
}


public extension View {
    
    /// Adds the negative of safeAreaInsets to this view if it's overlapping an edge that has safeAreaInsets
    /// - Returns: A view.
    func paddingSubtractingSafeArea() -> some View {
        InsetReader{ inset in
            self.padding(-inset)
        }
    }
    
    func paddingAddingSafeArea() -> some View {
        InsetReader{ inset in
            self.padding(inset)
        }
    }
    
}
