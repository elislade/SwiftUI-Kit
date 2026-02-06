import SwiftUI
import SwiftUIKitCore

extension EnvironmentValues {
    
    @Entry public var isNavigatedOn: Bool = false
    
}


extension View {
    
    nonisolated func isNavigatedOn(_ flag: Bool) -> some View {
        environment(\.isNavigatedOn, flag)
    }
    
}
