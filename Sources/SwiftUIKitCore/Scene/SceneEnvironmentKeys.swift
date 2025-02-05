import SwiftUI


struct SceneSizeKey: EnvironmentKey {
    static var defaultValue: CGSize { .zero }
}

struct SceneInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets { EdgeInsets() }
}

public extension EnvironmentValues {
    
    var sceneInsets: EdgeInsets {
        get { self[SceneInsetsKey.self] }
        set { self[SceneInsetsKey.self] = newValue }
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

public extension EnvironmentValues {
    
    var sceneSize: CGSize {
        get { self[SceneSizeKey.self] }
        set { self[SceneSizeKey.self] = newValue }
    }
    
}
