import SwiftUI


public extension View {
    
    /// - Parameter behaviour: The ``PresentationEnvironmentBehaviour`` to use when presenting views.
    nonisolated func presentationEnvironmentBehaviour(_ behaviour: PresentationEnvironmentBehaviour) -> some View {
        environment(\.presentationEnvironmentBehaviour, behaviour)
    }
    
}

public extension EnvironmentValues {
    
    @Entry var presentationEnvironmentBehaviour: PresentationEnvironmentBehaviour = .useContext
    
}

public enum PresentationEnvironmentBehaviour: Sendable, BitwiseCopyable {
    
    /// uses the environment of the presenter view.
    case usePresentation
    
    /// uses the environment of the  presentation context
    case useContext
    
}
