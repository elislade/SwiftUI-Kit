import SwiftUI


public enum PresentationPhase {
    case appearing
    case disappearing
    case presented
    
    public var isTransitioning: Bool {
        self != .presented
    }
    
}


public enum PresentingOnPhase {
    case none
    case presenting
    case dismissing
    case presentedOn
    
    public var isTransitioning: Bool {
        self == .dismissing || self == .presenting
    }
    
}


extension EnvironmentValues {
    
    /// The phase for the view being presented.
    @Entry public var presentationPhase: PresentationPhase = .presented
    
    /// The phase for the view being presented on.
    @Entry public var presentingOnPhase: PresentingOnPhase = .none
    
    /// A combination of both to know if there is a transition happening either above the view or on the view.
    /// - NOTE: You can use this to stop things that may effect transition performance as views that use `task` or `onAppear` may cause updates mid transition, causing hitches.
    public var presentationTransitioning: Bool {
        presentationPhase.isTransitioning || presentingOnPhase.isTransitioning
    }
    
}



extension View {
    
    public nonisolated func presentationPhase(_ phase: PresentationPhase) -> some View {
        environment(\.presentationPhase, phase)
    }
    
    public nonisolated func presentingOnPhase(_ phase: PresentingOnPhase) -> some View {
        environment(\.presentingOnPhase, phase)
    }
    
}
