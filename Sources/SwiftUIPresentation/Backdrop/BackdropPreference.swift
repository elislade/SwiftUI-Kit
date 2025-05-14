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
    public let interaction: BackdropInteraction
    public let view: (@MainActor () -> AnyView?)
    
    public var isInteractive: Bool {
        interaction != .disabled
    }
}


public enum BackdropInteraction: Hashable, Sendable, CaseIterable {
    case touchEndedDismiss
    case touchChangeDismiss
    case disabled
}


struct BackdropPreferenceKey: PreferenceKey {
    
    typealias Value = BackdropPreference?
    
    static func reduce(value: inout BackdropPreference?, nextValue: () -> BackdropPreference?) {
        let next = nextValue()
        if next != nil {
            value = next
        }
    }
    
}
