import SwiftUI


public struct BackdropPreference: Hashable {
    
    public static func == (lhs: BackdropPreference, rhs: BackdropPreference) -> Bool {
        lhs.interaction == rhs.interaction && lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(interaction)
    }
    
    public let id: UUID
    public let interaction: BackdropInteraction?
    public let view: (@MainActor () -> AnyView?)
    
    public var isInteractive: Bool {
        interaction != .none
    }
    
}


public struct BackdropInteraction: Hashable, Sendable {
    
    public enum Trigger: Hashable, Sendable, CaseIterable {
        /// Triggers at end of interaction.
        case ended
        
        /// Triggers on first change of interaction.
        case changed
        
        /// Triggers simultaneously with view benieth not interrupting events.
        case changedPassthrough
    }
    
    let trigger: Trigger
    let dismissalAmount: DismissalAmount
    
    init(_ trigger: Trigger, dismissalAmount: DismissalAmount = .once) {
        self.trigger = trigger
        self.dismissalAmount = dismissalAmount
    }
    
    public func dismiss(_ amount: DismissalAmount) -> Self {
        .init(trigger, dismissalAmount: amount)
    }
    
    public static let ended = BackdropInteraction(.ended)
    public static let changed = BackdropInteraction(.changed)
    public static let changedPassthrough = BackdropInteraction(.changedPassthrough)
    
    /// Backward compatability to legacy signatures.
    public static let touchEndedDismiss  = BackdropInteraction(.ended)
    public static let touchChangeDismiss = BackdropInteraction(.changed)

}


/// Backward compatability to legacy signatures.
extension Optional<BackdropInteraction> {
    
    public static var disabled: Self { .none }
    
}


struct BackdropPreferenceKey: PreferenceKey {
    
    typealias Value = BackdropPreference?
    
    static func reduce(value: inout BackdropPreference?, nextValue: () -> BackdropPreference?) {
        if let next = nextValue() {
            value = next
        }
    }
    
}
