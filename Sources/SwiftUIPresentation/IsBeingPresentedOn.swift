import SwiftUI

struct BeingPresentedOnKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


public extension EnvironmentValues {

    var _isBeingPresentedOn: Bool {
        get { self[BeingPresentedOnKey.self] }
        set { self[BeingPresentedOnKey.self] = newValue }
    }
    
    var isBeingPresentedOn: Bool {
        _isBeingPresentedOn
    }
    
}


public extension View {
    
    /// If flag is true the EnvironmentValue isBeingPresentedOn will also be true.
    /// - Parameter flag: A Bool indicating if the view is being presented on.
    /// - Returns: A view that has the isBeingPresentedOn environment value set.
    func isBeingPresentedOn(_ flag: Bool) -> some View {
        transformEnvironment(\._isBeingPresentedOn) { value in
            if flag {
                value = true
            }
        }
    }
    
}
