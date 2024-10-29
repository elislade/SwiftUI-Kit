import SwiftUI

struct EditingEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    
    /// An Bool value to indicate that an arbitrary editing mode is enabled.
    var isEditing: Bool {
        get { self[EditingEnvironmentKey.self] }
        set { self[EditingEnvironmentKey.self] = newValue }
    }
    
}


public extension View {
    
    
    /// Sets isEditing value for all child views.
    /// - Parameter editing: A Bool indicating that editing should be enabled. This value will not override with false values if the parent has set isEditing above.
    /// - Returns: A view that transforms its environement `isEditing` value.
    @inlinable func isEditing(_ editing: Bool) -> some View {
        transformEnvironment(\.isEditing){ value in
            if editing {
                value = true
            }
        }
    }
    
}
