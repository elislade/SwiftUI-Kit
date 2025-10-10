
/// The priority the system uses to tell how it should work with other interactions.
public enum InteractionPriority: Hashable, Identifiable, CaseIterable, Sendable, BitwiseCopyable {
    
    public var id: Int { hashValue }
    
    /// Uses `gesture` which  yields to other gestures lower in the responder chain.
    case normal
    
    /// Uses `highPriorityGesture` which has precidence over gestures lower in the responder chain unless they are also highPriority.
    case high
    
    /// Uses `simultaneousGesture` which works along any other gestures in the responder chain.
    case simultaneous
    
    /// Uses `onWindowDrag` raw events outside the responder chain and has access to all events regardless of other gestures above or below.
    /// - Note: This is the only option that supports more than one gesture location at a time.
    /// - Note: Use this when the originating gesture disappears, gets disabled or presented on top of mid-interaction.
    /// - Warning: It's suggested you look for a better way to architect your interaction before using this as it bypasses the responder chain and should be used with caution.
    case window
    
}


extension InteractionPriority {
    
    public static func == (lhs: Self, rhs: GesturePriority) -> Bool {
        lhs.gesturePriority == rhs
    }
    
    public static func == (lhs: GesturePriority, rhs: Self) -> Bool {
        lhs == rhs.gesturePriority
    }
    
    /// An equivalent ``GesturePriority``. If there is none `nil` is returned.
    public var gesturePriority: GesturePriority? {
        switch self {
        case .normal: .normal
        case .high: .high
        case .simultaneous: .simultaneous
        case .window: nil
        }
    }
    
    /// - Parameter gesturePriority: A ``GesturePriority``.
    public init?(_ gesturePriority: GesturePriority) {
        switch gesturePriority {
        case .none: return nil
        case .normal: self = .normal
        case .high: self = .high
        case .simultaneous: self = .simultaneous
        }
    }
    
}
