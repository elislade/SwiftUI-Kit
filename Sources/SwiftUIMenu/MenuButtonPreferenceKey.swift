import SwiftUI
import SwiftUIKitCore


struct MenuButtonValue: Equatable {
    
    static func == (lhs: MenuButtonValue, rhs: MenuButtonValue) -> Bool {
        lhs.id == rhs.id && lhs.globalRect == rhs.globalRect
    }
    
    let id: UUID
    let globalRect: CGRect
    //let anchor: Anchor<CGRect>
    let autoTriggerAfter: TimeInterval?
    let dismissOnAction: Bool
    let active: (Bool) -> Void
    let action: () -> Void
    
    init(
        id: UUID,
        globalRect: CGRect,
        //anchor: Anchor<CGRect>,
        autoTriggerAfter: TimeInterval? = nil,
        dismissOnAction: Bool = true,
        active: @escaping (Bool) -> Void,
        action: @escaping () -> Void
    ) {
        self.id = id
        //self.anchor = anchor
        self.globalRect = globalRect
        self.autoTriggerAfter = autoTriggerAfter
        self.dismissOnAction = dismissOnAction
        self.active = active
        self.action = action
    }
    
}


struct MenuButtonPreferenceKey: PreferenceKey {
    
    static var defaultValue: [MenuButtonValue] { [] }
    
    static func reduce(value: inout [MenuButtonValue], nextValue: () -> [MenuButtonValue]) {
        value.append(contentsOf: nextValue())
    }
    
}
