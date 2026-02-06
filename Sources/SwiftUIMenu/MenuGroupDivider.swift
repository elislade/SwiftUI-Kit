import SwiftUI

/// If this is inside SwiftUI Menu a normal divider will be represented as a group divider
public struct MenuGroupDivider: View {
    
    @Environment(\.isInMenu) private var isInMenu
    @Environment(\.menuStyle) private var style
    
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
            switch style {
            case .compact:
                Color.primary.opacity(0.1).frame(height: height)
            case .regular:
                Capsule()
                    .opacity(0.1)
                    .frame(height: 2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 0)
            }
        } else {
            Divider()
        }
    }
    
}


/// If this is inside SwiftUI Menu no divider will be shown as they are added automatically between items
public struct MenuDivider: View {
    
    @Environment(\.isInMenu) private var isInMenu
    @Environment(\.menuStyle) private var style
    
    public init() { }
    
    public var body: some View {
        if isInMenu {
            switch style {
            case .compact: Divider()
            case .regular: EmptyView()
            }
        }
    }
    
}
