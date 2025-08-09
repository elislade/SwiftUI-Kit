import SwiftUI


public struct InsetReader<Content: View> {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.insetReadingEnabled) private var enabled
    @Environment(\.sceneInsets) private var sceneInsets
    @Environment(\.sceneSize) private var sceneSize
    @State private var frame = CGRect()
    @State private var frozenInsets: EdgeInsets?
    
    private let content: @MainActor (EdgeInsets) -> Content
    
    private var shouldFreeze: Bool {
        !enabled || frozenState.isFrozen
    }
    
    public nonisolated init(@ViewBuilder _ content: @MainActor @escaping (EdgeInsets) -> Content) {
        self.content = content
    }
    
    private func calculate() -> EdgeInsets {
        let overlapsLeading = layoutDirection == .leftToRight ? frame.minX <= sceneInsets.leading : frame.maxX >= sceneSize.width - sceneInsets.leading
        let overlapsTrailing = layoutDirection == .leftToRight ? frame.maxX >= sceneSize.width - sceneInsets.trailing : frame.minX <= sceneInsets.trailing
        return EdgeInsets(
            top: frame.minY <= sceneInsets.top ? sceneInsets.top : 0,
            leading: overlapsLeading ? sceneInsets.leading : 0,
            bottom: frame.maxY >= sceneSize.height ? sceneInsets.bottom : 0,
            trailing: overlapsTrailing ? sceneInsets.trailing : 0
        )
    }
    
}

extension InsetReader: View {
    
    public var body: some View {
        content(frozenInsets ?? calculate())
            .onGeometryChangePolyfill(of: { $0.globalFrame() }){ frame = $0 }
            .onChangePolyfill(of: shouldFreeze, initial: true){
                frozenInsets = shouldFreeze ? calculate() : nil
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
                .animation(.fastSpringInterpolating, value: inset)
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
                //.animation(.fastSpringInterpolating, value: inset)
        }
    }
    
    /// Takes the current scene insets and applies them to this view using the system `safeAreaInset` modifier.
    ///
    /// - Warning: Using this modifer more then once on the same decendent will have undefined behaviour.
    ///
    /// - Parameter edges: The edges to apply the insets on. Defaults to all.
    /// - Returns: A view will applied `safeAreaInsets`
    func safeAreaFromSceneInset(_ edges: Edge.Set = .all) -> some View {
        InsetReader { inset in
            safeAreaInsets(inset, including: edges)
                .animation(.fastSpringInterpolating, value: inset)
        }
    }
    
    
    nonisolated func safeAreaInsets(_ inset: EdgeInsets, including edges: Edge.Set = .all) -> some View {
        safeAreaInset(edge: .top, spacing: 0){
            if edges.contains(.top) {
                Color.clear.frame(height: inset.top)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0){
            if edges.contains(.bottom) {
                Color.clear.frame(height: inset.bottom)
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0){
            if edges.contains(.trailing) {
                Color.clear.frame(width: inset.trailing)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0){
            if edges.contains(.leading) {
                Color.clear.frame(width: inset.leading)
            }
        }
    }
    
    nonisolated func safeAreaInsets(_ amount: Double, _ edges: Edge.Set = .all) -> some View {
        safeAreaInsets(.init(
            top: edges.contains(.top) ? amount : 0,
            leading: edges.contains(.leading) ? amount : 0,
            bottom: edges.contains(.bottom) ? amount : 0,
            trailing: edges.contains(.trailing) ? amount : 0
        ))
    }
    
}

public extension EnvironmentValues {
    
   @Entry var insetReadingEnabled: Bool = true
    
}


public extension View {
    
    /// Disables inset reading to all decendent views.
    /// While disabled, all inset reading will use last inset values before being disabled.
    /// Upon re-enabling, values will update to new values.
    /// 
    /// - Note: You can use this to temporarily disable inset reading while animating or dragging a view across inset bounds to stop sudden jumps to the UI as insets change.
    ///
    /// - Parameter disabled: Bool indicating whether it's disabled or not.
    /// - Returns: A view with the `insetReadingEnabled` environment value set to false.
    nonisolated func disableInsetReading(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.insetReadingEnabled){ enabled in
            if disabled {
                enabled = false
            }
        }
    }
    
}


extension GeometryProxy {
    
    func globalFrame(withSafeAreaInsetEdges edges: Edge.Set = .all) -> CGRect {
        frame(in: .global).addingInsets(safeAreaInsets, mask: edges)
    }
    
}


public extension CGRect {
    
    func addingInsets(
        _ insets: EdgeInsets,
        mask: Edge.Set = .all,
        isRTL: Bool = false
    ) -> CGRect {
        guard !mask.isEmpty else { return self }
        
        var rect = self
        
        if mask.contains(.top) { rect.size.height += insets.top }
        if mask.contains(.bottom) { rect.size.height += insets.bottom }
        
        if mask.contains(.leading) { rect.size.width += insets.leading }
        if mask.contains(.trailing) { rect.size.width += insets.trailing }
        
        return rect
    }
    
}
