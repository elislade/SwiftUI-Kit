import SwiftUI


public extension View {
    
    @available(*, deprecated, message: "Use interactionHoverGroup() along with a window InteractionPriority.")
    nonisolated func windowInteractionHoverContext(
        hitTestOnStart: Bool = false,
        hapticsEnabled: Bool = true
    ) -> some View {
        modifier(InteractionHoverWindowGroup(
            hapticsEnabled: hapticsEnabled,
            hitTestOnStart: hitTestOnStart,
            action: { _ in }
        ))
    }
    
    
    /// Adds a gesture and coordinates its event  to `onInteractionHover` elements.
    /// - Note: This happens inside the responder chain.
    /// - Parameters:
    ///   - delay: A Duration of how long to wait before the gesture activates. Defaults to zero attoseconds.
    ///   - action: A closure that gets sent ``InteractionHoverGroupEvent``. Defaults to an empty closure.
    /// - Returns: A modified view.
    @ViewBuilder nonisolated func interactionHoverGroup(
        priority: InteractionPriority = .normal,
        delay: Duration = .zero,
        perform action: @escaping (InteractionHoverGroupEvent) -> Void = { _ in }
    ) -> some View {
        if priority == .window {
            modifier(InteractionHoverWindowGroup(
                hapticsEnabled: false,
                hitTestOnStart: false,
                action: action
            ))
        } else {
            modifier(InteractionHoverGroupModifier(
                priority: priority,
                delay: delay,
                action: action
            ))
        }
    }
    
    
    @available(*, deprecated, renamed: "onInteractionHover(perform:)")
    nonisolated func onWindowInteractionHover(perform action: @escaping (WindowInteractionHoverPhase) -> Void) -> some View {
        onInteractionHover(perform: action)
    }
    
    /// Registers this view in the closest group as a interactionHover element.
    /// - Parameter action: A closure that receives the ``InteractionHoverPhase`` of the element in the closest group.
    /// - Returns: A modified view.
    nonisolated func onInteractionHover(perform action: @escaping (InteractionHoverPhase) -> Void) -> some View {
        modifier(InteractionHoverElementModifier(action: action))
    }
    
    @available(*, deprecated, renamed: "interactionHoverDisabled")
    nonisolated func windowInteractionHoverDisabled(_ disabled: Bool = true) -> some View {
        interactionHoverDisabled(disabled)
    }
    
    /// Disables all interactionHover elements inside this view.
    /// - Parameter disabled: Bool indicating if should be disabling or not. Defaults to true.
    /// - Returns: A modified view.
    nonisolated func interactionHoverDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.interactionHoverEnabled){ enabled in
            if disabled {
                enabled = false
            }
        }
    }
}


extension EnvironmentValues {
    
    @Entry var interactionHoverEnabled = true
    @Entry var interactionGroupCoordinateSpace: CoordinateSpace = .global
    
}


@available(*, deprecated, renamed: "InteractionHoverPhase")
public typealias WindowInteractionHoverPhase = InteractionHoverPhase


public enum InteractionHoverPhase: Hashable, Sendable, BitwiseCopyable {
    
    /// Interaction entered element.
    case entered
    
    /// Interaction left element.
    case left
    
    /// Interaction ended on element.
    case ended
    
    public var hasEntered: Bool { self == .entered }
    public var hasLeft: Bool { self == .left }
    public var hasEnded: Bool { self == .ended }
    
}


@dynamicMemberLookup public struct InteractionHoverGroupEvent: Equatable, Sendable {
    
    public let date: Date
    public let phase: Phase
    
    public enum Phase: Hashable, Sendable, BitwiseCopyable {
        
        /// Interaction started.
        case started
        
        /// Interaction entered an element.
        case entered
        
        /// Interaction exited an element.
        case exited
        
        /// Interaction ended.
        case ended
        
        public var hasStarted: Bool { self == .started }
        public var hasChanged: Bool { self == .entered || self == .exited }
        public var hasEnded: Bool { self == .ended }
        
    }
    
    public subscript<Subject>(dynamicMember keyPath: KeyPath<Phase, Subject>) -> Subject {
        phase[keyPath: keyPath]
    }
    
}


extension BidirectionalCollection where Element == InteractionHoverGroupEvent {
    
    public var endedOnElement: Bool {
        guard count > 1 else { return false }
        let last = self[index(endIndex, offsetBy: -1)]
        let penultimate = self[index(endIndex, offsetBy: -2)]
        return last.hasEnded && penultimate.phase == .entered
    }
    
}
