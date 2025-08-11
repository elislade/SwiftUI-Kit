import SwiftUI
import SwiftUIKitCore


public extension EnvironmentValues {
    
    @Entry var presentationDepth: Int = 0
    @Entry var presentationContextNamespaces: [Namespace.ID] = []
    
    var closestPresentationContextNamespace: Namespace.ID? {
        presentationContextNamespaces.last
    }
    
}


public extension View {
    
    nonisolated func presentationNamespace(_ namespace: Namespace.ID, active: Bool = true) -> some View {
        transformEnvironment(\.presentationContextNamespaces){ namespaces in
            if active {
                namespaces.append(namespace)
            }
        }
    }
    
}
