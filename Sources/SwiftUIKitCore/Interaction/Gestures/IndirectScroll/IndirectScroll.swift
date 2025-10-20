import SwiftUI


extension View {
    
    /// Defines a group that coordinates indirect child gestures.
    /// - Warning: Without at least one of these in your view hierarchy, `indirectScrollGestures` will not work.
    /// - Warning: Changing `isActive` will change this views identity.
    /// - Parameter isActive: A boolean indicating if this group is active. Defaults to true.
    /// - Returns: A modified view.
    nonisolated public func indirectScrollGroup(isActive: Bool = true) -> some View {
        modifier(IndirectScrollGroupModifier(isActive: isActive))
    }
    
    
    /// A gesture that is not directly inputed on the users screen. Eg. trackpad or mouse scroll.
    /// - Warning: An `indirectScrollGesture` needs to be accompanied by at least one parent `indirectScrollGroup`.
    nonisolated public func indirectScrollGesture(_ gesture: IndirectScrollGesture) -> some View {
        modifier(IndirectScrollModifier(gesture: gesture))
    }
    
    
    /// Sets whether indirect scroll child gestures should invertY or not.
    /// - Note: This will take into account parent and invert the value that was set above. Eg. two sequental calls to invert is the same as no calls.
    /// - Parameter shouldInvert: Bool indicating whether to invert or not. Defaults to true.
    /// - Returns: A modified view.
    nonisolated public func indirectScrollInvertY(_ shouldInvert: Bool = true) -> some View {
        transformEnvironment(\.indirectScrollInvertY){ invert in
            if shouldInvert {
                invert.toggle()
            }
        }
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


extension EnvironmentValues {
    
    @Entry var indirectScrollInvertY: Bool = false
    
}
