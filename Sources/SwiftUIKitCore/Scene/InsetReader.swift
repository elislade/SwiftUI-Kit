import SwiftUI


public struct InsetReader<Content: View>: View {
    
    @Environment(\.insetReadingDisabled) private var disabled
    @Environment(\.sceneInsets) private var sceneInsets
    @Environment(\.sceneSize) private var sceneSize
    @State private var frame = CGRect()
    @State private var disabledInsets: EdgeInsets?
    
    private let content: @MainActor (EdgeInsets) -> Content
    
    public init(@ViewBuilder _ content: @MainActor @escaping (EdgeInsets) -> Content) {
        self.content = content
    }
    
    private func calculate() -> EdgeInsets {
        EdgeInsets(
            top: frame.minY <= sceneInsets.top ? sceneInsets.top : 0,
            leading: frame.minX <= sceneInsets.leading ? sceneInsets.leading : 0,
            bottom: frame.maxY >= sceneSize.height ? sceneInsets.bottom : 0,
            trailing: frame.maxX >= sceneSize.width - sceneInsets.trailing ? sceneInsets.trailing : 0
        )
    }
    
    public var body: some View {
        content(disabledInsets ?? calculate())
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ frame = $0 }
            .onChangePolyfill(of: disabled, initial: true){
                disabledInsets = disabled ? calculate() : nil
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
                .animation(.fastSpringInterpolating, value: inset)
        }
    }
    
}


struct DisableInsetReaderKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


extension EnvironmentValues {
    
    var insetReadingDisabled: Bool {
        get { self[DisableInsetReaderKey.self] }
        set { self[DisableInsetReaderKey.self] = newValue }
    }
    
}


public extension View {
    
    nonisolated func disableInsetReading(_ disabled: Bool = true) -> some View {
        environment(\.insetReadingDisabled, disabled)
    }
    
}
