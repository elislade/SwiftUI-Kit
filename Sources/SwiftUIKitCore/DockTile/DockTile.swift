import SwiftUI


public extension View {
    
    #if os(macOS)
    
    func appDockTile<ID: Hashable, Content: View>(id update: ID, @ViewBuilder _ content: @escaping () -> Content) -> some View {
        modifier(AppDockTileModifier(tileID: update, tile: content))
    }
    
    func windowDockTile<ID: Hashable, Content: View>(id update: ID, @ViewBuilder _ content: @escaping () -> Content) -> some View {
        InlineState(UUID()){ id in
            preference(
                key: WindowDockTilePreferenceKey.self,
                value: .init(
                    id: id,
                    updateValue: update,
                    view: AnyView(content())
                )
            )
        }
    }
    
    func windowDockTile<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        InlineState(UUID()){ id in
            preference(
                key: WindowDockTilePreferenceKey.self,
                value: .init(
                    id: id,
                    updateValue: Int.zero,
                    view: AnyView(content())
                )
            )
        }
    }
    
    #else
    
    func appDockTile<ID: Hashable, Content: View>(id update: ID, @ViewBuilder _ content: @escaping () -> Content) -> Self {
        self
    }
    
    func windowDockTile<ID: Hashable, Content: View>(id update: ID, @ViewBuilder _ content: @escaping () -> Content) -> Self {
        self
    }
    
    func windowDockTile<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> Self {
        self
    }
    
    #endif
    
}


struct DockTilePreference: Equatable, @unchecked Sendable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.updateValue == rhs.updateValue
    }
    
    let id: UUID
    let updateValue: AnyHashable
    let view: AnyView
}


struct WindowDockTilePreferenceKey: PreferenceKey {
    
    static var defaultValue: DockTilePreference? { nil }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let next = nextValue() {
            value = next
        }
    }
    
}

