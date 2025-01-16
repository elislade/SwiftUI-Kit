import SwiftUI


public extension View {
    
    /// A gesture that is not directly inputed on the users screen. Eg. trackpad or mouse scroll.
    @ViewBuilder func indirectGesture<Gesture: IndirectGesture>(_ gesture: Gesture) -> some View {
        if let gesture = gesture as? IndirectScrollGesture {
            modifier(IndirectScrollModifier(gesture: gesture))
        } else {
            self
        }
    }
    
}


public enum EventMaskEvaluationBehaviour: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    
    /// Over the given phases of an event the mask will be evaluated continuously.
    case continuous
    
    /// Once an event has started with a given mask it will not be evaluated again untill the event ends.
    /// - Note: This does **not** mean the event will not evaluate continuously it means the **mask** will not evaluate continuously.
    case locked
    
    public var isLocked: Bool {
        self == .locked
    }
    
    public var isContinuous: Bool {
        self == .continuous
    }
    
}
