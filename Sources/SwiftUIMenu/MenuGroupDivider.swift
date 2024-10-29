import SwiftUI

/// If this is inside SwiftUI Menu a normal divider will be represented as a group divider
public struct MenuGroupDivider: View {
    
    @Environment(\.isInMenu) private var isInMenu
    
    public init() { }
    
    private var height: Double {
        #if os(macOS)
        5
        #else
        10
        #endif
    }
    
    public var body: some View {
        if isInMenu {
            Color.primary.opacity(0.1).frame(height: height)
        } else {
            Divider()
        }
    }
    
}


/// If this is inside SwiftUI Menu no divider will be shown as they are added automatically between items
public struct MenuDivider: View {
    
    @Environment(\.isInMenu) private var isInMenu
    
    public init() { }
    
    public var body: some View {
        if isInMenu {
            Divider()
        }
    }
    
}


#Preview {
    MenuGroupDivider()
}
