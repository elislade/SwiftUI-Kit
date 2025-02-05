import SwiftUI


extension View {
    
    public func windowPickerPositioning(_ positioning: WindowPickerPositioning) -> some View {
        preference(key: WindowPickerPositioningPreference.self, value: positioning)
    }
    
}


struct WindowPickerPositioningPreference: PreferenceKey {
    
    static let defaultValue: WindowPickerPositioning? = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let next = nextValue() {
            value = next
        }
    }
    
}


public enum WindowPickerPositioning: Int, Hashable, CaseIterable, Codable, Sendable, BitwiseCopyable {
    
    /// The window picker controls the positioning.
    case managed = 0
    
    /// The window picker has no control over the windows size and positioning.
    case fixed = 1
    
    /// The window picker will hide this window.
    case hidden = 2
    
}


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

extension NSWindow {
    
    func updatePickerPositioning(_ positioning: WindowPickerPositioning) {
        switch positioning {
        case .managed:
            collectionBehavior.insert(.managed)
            collectionBehavior.remove(.transient)
            collectionBehavior.remove(.stationary)
        case .fixed:
            collectionBehavior.insert(.stationary)
            collectionBehavior.remove(.transient)
            collectionBehavior.remove(.managed)
        case .hidden:
            collectionBehavior.insert(.transient)
            collectionBehavior.remove(.managed)
            collectionBehavior.remove(.stationary)
            collectionBehavior.remove(.managed)
        }
    }
    
}

#endif
