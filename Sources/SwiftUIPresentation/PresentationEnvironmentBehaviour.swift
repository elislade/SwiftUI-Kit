import SwiftUI


public extension View {
    
    /// - Parameter behaviour: The ``PresentationEnvironmentBehaviour`` to use when presenting views.
    func presentationEnvironmentBehaviour(_ behaviour: PresentationEnvironmentBehaviour) -> some View {
        environment(\.presentationEnvironmentBehaviour, behaviour)
    }
    
}

struct PresentationEnvironmentBehaviourKey: EnvironmentKey {
    
    static let defaultValue: PresentationEnvironmentBehaviour = .useContext
    
}

extension EnvironmentValues {
    
    public var presentationEnvironmentBehaviour: PresentationEnvironmentBehaviour {
        get { self[PresentationEnvironmentBehaviourKey.self] }
        set { self[PresentationEnvironmentBehaviourKey.self] = newValue }
    }
    
}

public enum PresentationEnvironmentBehaviour: Sendable, BitwiseCopyable {
    
    /// uses the environment of the presenter view.
    case usePresentation
    
    /// uses the environment of the  presentation context
    case useContext
    
}
