import SwiftUI
import SwiftUICore

public enum PresentationType {
    case fullscreen
    case overCurrentContext
}


public struct DismissPresentationAction: Equatable {
    
    public static func == (lhs: DismissPresentationAction, rhs: DismissPresentationAction) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let closure: () -> Void
    
    public init(id: UUID = .init(), closure: @escaping () -> Void) {
        self.id = id
        self.closure = closure
    }
    
    public func callAsFunction() {
        closure()
    }
    
}

struct DismissPresentation: EnvironmentKey {
    
    static var defaultValue: DismissPresentationAction = .init(id: .init(), closure: {})
    
}

public extension EnvironmentValues {
    
    var dismissPresentation: DismissPresentationAction {
        get { self[DismissPresentation.self] }
        set { self[DismissPresentation.self] = newValue }
    }
    
}


public extension View {
    
    func handleDismissPresentation(id: UUID, action: @escaping () -> Void) -> some View {
        InlineEnvironmentReader(\.isBeingPresentedOn){ isBeingPresentedOn in
            self.transformEnvironment(\.dismissPresentation) { value in
                // only set value if view is not being presented on
                if isBeingPresentedOn == false {
                    value = .init(id: id, closure: action)
                }
            }
        }
    }
    
}


// MARK: ScenePresentationTraits


struct ScenePresentationTraitsKey: EnvironmentKey {
    static var defaultValue: PresentationTraits = []
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
