import SwiftUI
import SwiftUIKitCore


struct ScenePresentationTraitsKey: EnvironmentKey {
    
    static var defaultValue: PresentationTraits { [] }
    
}


public extension EnvironmentValues {
    
    /// PresentationTraits for current Scene relating to UIWindowScene
    /// 
    /// - Note: When a views UIWindowScene isFullscreen propetry is true these traits will also include a fullscreen trait.
    ///
    /// On iOS a scene will not be fullscreen when iPad multitasking.
    ///
    /// On macOS a scene will be fullscreen when a window is taken fullscreen.
    ///
    /// Pinned(edge) traits could in theory also be added on both macOS and iPadOS.
    ///
    /// iPadOS would need access to info on where the window is pinned to in SplitView mode.
    ///
    /// Stage Manager would not influence pinned traits.
    ///
    /// macOS is open enough that it should be possible to derive pinned traits when not in Stage Manager.
    /// 
    /// There could even be a preference key that when set would allow window auto snapping to that pinned location on macOS.
    var scenePresentationTraits: PresentationTraits {
        get { self[ScenePresentationTraitsKey.self] }
        set { self[ScenePresentationTraitsKey.self] = newValue }
    }
    
}
