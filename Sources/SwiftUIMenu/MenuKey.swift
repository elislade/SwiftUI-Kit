import SwiftUI

struct MenuKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}


public extension EnvironmentValues {
    
    var isInMenu: Bool {
        get{ self[MenuKey.self] }
        set{ self[MenuKey.self] = newValue }
    }
    
}
