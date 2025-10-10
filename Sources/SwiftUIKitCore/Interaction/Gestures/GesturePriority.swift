import SwiftUI


public enum GesturePriority: Hashable, Identifiable, CaseIterable, Sendable, BitwiseCopyable {
    
    public var id: Int { hashValue }
    
    /// Does  **NOT** use the gesture in any way.
    case none
    
    /// Uses `gesture` which  yields to other gestures lower in the responder chain.
    case normal
    
    /// Uses `highPriorityGesture` which has precidence over gestures lower in the responder chain unless they are also highPriority.
    case high
    
    /// Uses `simultaneousGesture` which works along any other gestures in the responder chain.
    case simultaneous
    
}


extension View {
    
    /// Unifies calls to `highPriorityGesture`,  `simultaneousGesture`, and `gesture` into an enum instead of separate view modifiers.
    /// - Parameters:
    ///   - priority: ``GesturePriority``.
    ///   - gesture: `some Gesture`.
    /// - Returns: A modified view.
    public nonisolated func gesture(_ priority: GesturePriority, _ gesture: some Gesture) -> some View {
        self
            .highPriorityGesture(gesture, including: priority == .high ? .all : .subviews)
            .simultaneousGesture(gesture, including: priority == .simultaneous ? .all : .subviews)
            .gesture(gesture, including: priority == .normal ? .all : .subviews)
    }
    
}
