import SwiftUI


extension View {
    
    /// Defines a group that coordinates indirect child gestures.
    /// - Warning: Without at least one of these in your view hierarchy, `indirectScrollGestures` will not work.
    /// - Returns: A modified view.
    public nonisolated func indirectScrollGroup() -> some View {
        modifier(IndirectScrollGroupModifier())
    }
    
    
    /// A gesture that is not directly inputed on the users screen. Eg. trackpad or mouse scroll.
    /// - Warning: An `indirectScrollGesture` needs to be accompanied by at least one parent `indirectScrollGroup`.
    public nonisolated func indirectScrollGesture(_ gesture: IndirectScrollGesture) -> some View {
        modifier(IndirectScrollModifier(gesture: { gesture } ))
    }
    
}


public enum EventMaskEvaluationPhase: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    
    /// The mask will only evaluate on event begin phase.
    case onBegin
    
    /// The mask will evaluate on every event change phase.
    case onChange
    
    public var isContinuous: Bool {
        self == .onChange
    }
    
}
