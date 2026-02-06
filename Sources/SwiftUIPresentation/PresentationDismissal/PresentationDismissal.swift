import SwiftUI
import SwiftUIKitCore


public struct DismissalAmount: RawRepresentable, Hashable, Sendable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    /// Dismisses once.
    public static let once = DismissalAmount(rawValue: 0)
    
    /// Dismisses closest context.
    public static let context = DismissalAmount(rawValue: 1)
    
    /// Dismisses to root.
    public static let all = DismissalAmount(rawValue: .max)
    
}

public struct DismissPresentationAction: Sendable {

    let amount: DismissalAmount?
    let closure: @MainActor (DismissalAmount) -> Void
    
    public init(type: DismissalAmount? = nil, closure: @MainActor @escaping (DismissalAmount) -> Void) {
        self.amount = type
        self.closure = closure
    }
    
    @MainActor public func callAsFunction() {
        closure(.once)
    }
    
    @MainActor public func callAsFunction(_ amount: DismissalAmount) {
        closure(amount)
    }
    
}

public extension EnvironmentValues {
    
    @Entry var dismissPresentation: DismissPresentationAction = .init(closure: { _ in })
    
    /// Similar to dismiss but infers that it wants to be coordinated with another dismissal lower down in the view tree.
    /// - NOTE: This means it should only be removed on topmost coordinator at the end of the transaction.
    @Entry var coordinatedDismiss: DismissPresentationAction = .init(closure: { _ in })
    
}

extension View {
    
    @available(*, deprecated, renamed: "presentationDismissHandler(_:enabled:perform:)")
    nonisolated public func dismissPresentationHandler(_ handles: DismissalAmount = .once, enabled: Bool = true, perform action: @MainActor @escaping () -> Void) -> some View {
        presentationDismissHandler(handles, enabled: enabled, perform: action)
    }
    
    nonisolated public func presentationDismissHandler(_ handles: DismissalAmount = .once, enabled: Bool = true, perform action: @MainActor @escaping () -> Void) -> some View {
        modifier(PresentationDismissalModifier(action: action, handles: handles, enabled: enabled))
    }
    
    nonisolated public func onCoordinatedDismiss(perform action: @MainActor @escaping () -> Void) -> some View {
        modifier(CoordinatedDismissalModifier(action: action))
    }
    
}
