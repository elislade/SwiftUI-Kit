import SwiftUI
import SwiftUIKitCore

struct NavViewPendingDestinationValue: EnvironmentKey {
    
    static var defaultValue: NavViewDestinationValue? { nil }
    
}

extension EnvironmentValues {
    
    var destinationNavValue: NavViewDestinationValue? {
        get { self[NavViewPendingDestinationValue.self] }
        set { self[NavViewPendingDestinationValue.self] = newValue }
    }
    
}
