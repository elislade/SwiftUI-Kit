import SwiftUI


struct PreferredGestureMask: PreferenceKey {
    
    typealias Value = GestureMask?
    
    static func reduce(value: inout GestureMask?, nextValue: () -> GestureMask?) {
        if let next = nextValue() {
            value = next
        }
    }
    
}

public extension View {
    
    /// Ask for preferred gesture mask of some parent gesture
    nonisolated func preferredParentGestureMask(_ mask: GestureMask?) -> some View {
        preference(key: PreferredGestureMask.self, value: mask)
    }
    
    /// Listen for child requests of mask change
    nonisolated func onPreferredGestureMaskChange(perform action: @escaping (GestureMask?) -> Void) -> some View {
        onPreferenceChange(PreferredGestureMask.self, perform: action)
    }
    
}
