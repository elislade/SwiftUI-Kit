import SwiftUI
import SwiftUIKitCore


extension EnvironmentValues {
    
    @Entry public var presentationDepth: Int = 0
    @Entry public var presentationContextNamespaces: [Namespace.ID] = []
    
    nonisolated public var closestPresentationContextNamespace: Namespace.ID? {
        presentationContextNamespaces.last
    }
    
}


extension View {
    
    nonisolated public func presentationNamespace(_ namespace: Namespace.ID, active: Bool = true) -> some View {
        transformEnvironment(\.presentationContextNamespaces){ namespaces in
            if active {
                namespaces.append(namespace)
            }
        }
    }
    
}
