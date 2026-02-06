import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


struct NavViewTitle: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ownerID == rhs.ownerID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ownerID)
    }
    
    let ownerID: UniqueID
    let view: AnyView
    
}

struct NavViewBreadcrumbs: PreferenceKey {
    
    static var defaultValue: [NavViewTitle] { [] }
    
    static func reduce(value: inout [NavViewTitle], nextValue: () -> [NavViewTitle]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct NavViewBreadcrumb {
    
    let id: UniqueID
    let isActive: Bool
    
    @State private var view: AnyView?
    
}

extension NavViewBreadcrumb : ViewModifier {
    
    func body(content: Content) -> some View {
        content.onPreferenceChange(PresentationKey<NavBarItemMetadata>.self){ items in
            view = items.filter({ $0.placement == .title }).last?.view
        }
        .preference(
            key: NavViewBreadcrumbs.self,
            value: view != nil && isActive ? [NavViewTitle(ownerID: id, view: view!)] : []
        )
    }
    
}

extension View {
    
    nonisolated func navViewBreadcrumb(for id: UniqueID, isActive: Bool = true) -> some View {
        modifier(NavViewBreadcrumb(id: id, isActive: isActive))
    }
    
}

extension EnvironmentValues {
    
    @Entry var navViewBreadcrumbs: [NavViewTitle] = []
    
}
