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
    /// - Parameter edges: The Set of Edges you want to be included in the padding. Defaults to `.all`.
    /// - Returns: A view.
    func paddingSubtractingSafeArea(_ edges: Edge.Set = .all) -> some View {
        InsetReader{ inset in
            self.padding(.leading, edges.contains(.leading) ? -inset.leading : 0)
                .padding(.top, edges.contains(.top) ? -inset.top : 0)
                .padding(.trailing, edges.contains(.trailing) ? -inset.trailing : 0)
                .padding(.bottom, edges.contains(.bottom) ? -inset.bottom : 0)
        }
    }
    
    /// Adds the safeAreaInsets to this view if it's overlapping an edge that has safeAreaInsets.
    /// - Parameter edges: The Set of Edges you want to be included in the padding.  Defaults to `.all`.
    /// - Returns: A view.
    func paddingAddingSafeArea(_ edges: Edge.Set = .all) -> some View {
        InsetReader{ inset in
            self
                .padding(.leading, edges.contains(.leading) ? inset.leading : 0)
                .padding(.top, edges.contains(.top) ? inset.top : 0)
                .padding(.trailing, edges.contains(.trailing) ? inset.trailing : 0)
                .padding(.bottom, edges.contains(.bottom) ? inset.bottom : 0)
        }
    }
    
}
