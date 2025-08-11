import SwiftUI

extension EnvironmentValues {
    
    @Entry public internal(set) var isInMenu: Bool = false
    @Entry public var menuStyle: MenuStyle = .regular
    
    @Entry internal var menuVisualDepth: Double = 1
    @Entry internal var menuRoundness: Double = 1
    
}


public enum MenuStyle: Int, CaseIterable, Sendable {
    case compact
    case regular
}
