import SwiftUI
import SwiftUIKitCore

struct MenuItemInsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: [EdgeInsets] = []
    
    static func reduce(value: inout [EdgeInsets], nextValue: () -> [EdgeInsets]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct MenuItemInsetKey: EnvironmentKey {
    
    #if os(iOS)
    static var defaultValue: EdgeInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
    #else
    static var defaultValue: EdgeInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
    #endif
    
}


public extension EnvironmentValues {
    
    var menuItemInsets: EdgeInsets {
        get { self[MenuItemInsetKey.self] }
        set { self[MenuItemInsetKey.self] = newValue }
    }
    
}


extension View {
    
    public func applyMenuItemInsets(_ edges: Edge.Set = .all) -> some View {
        InlineEnvironmentReader(\.menuItemInsets){
            self
                .padding(.leading, edges.contains(.leading) ? $0.leading : 0)
                .padding(.trailing, edges.contains(.trailing) ? $0.trailing : 0)
                .padding(.top, edges.contains(.top) ? $0.top : 0)
                .padding(.bottom, edges.contains(.bottom) ? $0.bottom : 0)
                .menuItemInset(edges, 0)
        }
    }
    
    public func preferMenuItemInsets(_ edges: Edge.Set, _ value: CGFloat) -> some View {
        preference(
            key: MenuItemInsetPreferenceKey.self,
            value: [
                .init(
                    top: edges.contains(.top) ? value : 0,
                    leading: edges.contains(.leading) ? value : 0,
                    bottom: edges.contains(.bottom) ? value : 0,
                    trailing: edges.contains(.trailing) ? value : 0
                )
            ]
        )
    }
    
    func menuItemInsetPadding(_ edges: Edge.Set, _ value: CGFloat? = nil) -> some View {
        transformEnvironment(\.menuItemInsets) { insets in
            if edges.contains(.leading) { insets.leading += value ?? 16 }
            if edges.contains(.trailing) { insets.trailing += value ?? 16 }
            if edges.contains(.top) { insets.top += value ?? 16 }
            if edges.contains(.bottom) { insets.bottom += value ?? 16 }
        }
    }
    
    func menuItemInset(_ edges: Edge.Set, _ value: CGFloat?) -> some View {
        transformEnvironment(\.menuItemInsets) { insets in
            if edges.contains(.leading), let value { insets.leading = value }
            if edges.contains(.trailing), let value { insets.trailing = value }
            if edges.contains(.top), let value { insets.top = value }
            if edges.contains(.bottom), let value { insets.bottom = value }
        }
    }
    
    func childMenuItemInsetsPreferencesChange(_ closure: @escaping ([EdgeInsets]) -> Void) -> some View {
        onPreferenceChange(MenuItemInsetPreferenceKey.self) { value in
            closure(value)
        }
    }
    
    func hasChildMenuItemInsetPreferences(_ closure: @escaping (Bool) -> Void) -> some View {
        onPreferenceChange(MenuItemInsetPreferenceKey.self) { value in
            closure(!value.isEmpty)
        }
    }
    
}
