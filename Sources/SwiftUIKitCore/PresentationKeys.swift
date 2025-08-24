import SwiftUI

extension EnvironmentValues {

    @Entry public var isBeingPresentedOn = false
    
}


public extension View {
    
    /// If flag is true the EnvironmentValue isBeingPresentedOn will also be true.
    /// - Parameter flag: A Bool indicating if the view is being presented on.
    /// - Returns: A view that has the isBeingPresentedOn environment value set.
    nonisolated func isBeingPresentedOn(_ flag: Bool) -> some View {
        transformEnvironment(\.isBeingPresentedOn) { value in
            if flag {
                value = true
            }
        }
    }
    
}
