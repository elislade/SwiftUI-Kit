import SwiftUI
import SwiftUIKitCore


struct MenuButtonValue: Equatable, Sendable {
    
    static func == (lhs: MenuButtonValue, rhs: MenuButtonValue) -> Bool {
        lhs.id == rhs.id && lhs.globalRect == rhs.globalRect
    }
    
    let id: UUID
    let globalRect: CGRect
    var dwellDuration: TimeInterval?
    let dismissOnAction: Bool
    var actionBehaviour: MenuActionTriggerBehaviour
    let active: @MainActor (Bool) -> Void
    let action: @MainActor() -> Void
    
    init(
        id: UUID,
        globalRect: CGRect,
        dismissOnAction: Bool = true,
        active: @escaping @Sendable (Bool) -> Void,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.globalRect = globalRect
        self.dwellDuration = nil
        self.dismissOnAction = dismissOnAction
        self.active = active
        self.action = action
        self.actionBehaviour = .afterDismissal
    }
    
}


struct MenuButtonPreferenceKey: PreferenceKey {
    
    static var defaultValue: [MenuButtonValue] { [] }
    
    static func reduce(value: inout [MenuButtonValue], nextValue: () -> [MenuButtonValue]) {
        value.append(contentsOf: nextValue())
    }
    
}
