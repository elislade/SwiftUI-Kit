import SwiftUI


// MARK: - SceneInsets

struct SceneProxyKey: EnvironmentKey {
    static var defaultValue: GeometryProxy? { nil }
}

struct SceneInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets { EdgeInsets() }
}

public extension EnvironmentValues {
    
    var sceneInsets: EdgeInsets {
        get { self[SceneInsetsKey.self] }
        set { self[SceneInsetsKey.self] = newValue }
    }
    
    var sceneProxy: GeometryProxy? {
        get { self[SceneProxyKey.self] }
        set { self[SceneProxyKey.self] = newValue }
    }
    
}


public extension View {
    
    func sceneInset(_ newInsets: EdgeInsets) -> some View {
        transformEnvironment(\.sceneInsets) { insets in
            insets = newInsets
        }
    }
    
    func sceneInset(_ edges: Edge.Set = .all, _ value: CGFloat? = nil) -> some View {
        transformEnvironment(\.sceneInsets) { insets in
            if edges.contains(.top) { insets.top = value ?? .defaultSceneInsetPadding }
            if edges.contains(.leading) { insets.leading = value ?? .defaultSceneInsetPadding }
            if edges.contains(.trailing) { insets.trailing = value ?? .defaultSceneInsetPadding }
            if edges.contains(.bottom) { insets.bottom = value ?? .defaultSceneInsetPadding }
        }
    }
    
    func sceneInsetPadding(_ edges: Edge.Set = .all, _ value: CGFloat? = nil) -> some View {
        transformEnvironment(\.sceneInsets) { insets in
            if edges.contains(.top) { insets.top += value ?? .defaultSceneInsetPadding }
            if edges.contains(.leading) { insets.leading += value ?? .defaultSceneInsetPadding }
            if edges.contains(.trailing) { insets.trailing += value ?? .defaultSceneInsetPadding }
            if edges.contains(.bottom) { insets.bottom += value ?? .defaultSceneInsetPadding }
        }
    }
    
}

public extension CGFloat {
    static let defaultSceneInsetPadding: CGFloat = 16
}


// MARK: - SceneSize

public extension EnvironmentValues {
    var sceneSize: CGSize {
        sceneProxy?.size ?? .zero
    }
}
