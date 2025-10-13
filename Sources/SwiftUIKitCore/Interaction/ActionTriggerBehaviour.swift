import SwiftUI


public enum ActionTriggerBehaviour: Hashable, Sendable, BitwiseCopyable, Identifiable {
    
    public var id: Int { hashValue }
    
    case immediate
    case afterDelay(Duration)
    case onDisappear
}


extension View {
    
    public nonisolated func actionTriggerBehaviour(_ behaviour: ActionTriggerBehaviour) -> some View {
        environment(\.actionTriggerBehaviour, behaviour)
    }
    
}


extension EnvironmentValues {
    
    @Entry public var actionTriggerBehaviour: ActionTriggerBehaviour = .immediate
    
}
