import SwiftUI

struct FocusPresentationMetadata: Equatable, Sendable {
    
    static func == (lhs: FocusPresentationMetadata, rhs: FocusPresentationMetadata) -> Bool {
        lhs.namespace == rhs.namespace
    }
    
    let namespace: Namespace.ID
    let accessory: @MainActor () -> AnyView?
    
}
