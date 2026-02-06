import SwiftUI


extension EnvironmentValues {
    
    @Entry public var buttonContentMode: ContentMode? = nil
    
}


extension View {
    
    /// Specifies how buttons should resize along their primary axis like `buttonSizing()`.
    /// - Note: Nil signifies that buttonSizing should be left up to an individual `buttonStyle`.
    /// - Parameter mode: The ContentMode to use.
    /// - Returns: A modified view.
    nonisolated public func buttonContentMode(_ mode: ContentMode?) -> some View {
        environment(\.buttonContentMode, mode)
    }
    
}
