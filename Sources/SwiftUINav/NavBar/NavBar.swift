import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


extension View {
    
    nonisolated internal func navBar(
        _ placement: NavBarItemMetadata.Placement,
        hidden: Bool = false,
        priority: UInt8,
        @ViewBuilder view: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(NavBarPresenter(
            meta: .init(placement: placement, hidden: hidden, priority: priority),
            label: view
        ))
    }
    
    nonisolated public func navBar(
        _ placement: NavBarItemMetadata.Placement,
        hidden: Bool = false,
        @ViewBuilder view: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(NavBarPresenter(
            meta: .init(placement: placement, hidden: hidden, priority: 1),
            label: view
        ))
    }
    
    nonisolated public func navBarTitle(hidden: Bool = false, _ text: Text) -> some View {
        navBar(.title){ text.font(.title2[.semibold]) }
    }
    
    nonisolated public func navBarTitle(hidden: Bool = false, @ViewBuilder view: @MainActor @escaping () -> some View) -> some View {
        navBar(.title, hidden: hidden, view: view)
    }
    
    nonisolated public func navBarLeading(hidden: Bool = false, @ViewBuilder view: @MainActor @escaping () -> some View) -> some View {
        navBar(.leading, hidden: hidden, view: view)
    }
    
    nonisolated public func navBarTrailing(hidden: Bool = false, @ViewBuilder view: @MainActor @escaping () -> some View) -> some View {
        navBar(.trailing, hidden: hidden, view: view)
    }
    
    nonisolated public func navBarAccessory(hidden: Bool = false, @ViewBuilder view: @MainActor @escaping () -> some View) -> some View {
        navBar(.accessory, hidden: hidden, view: view)
    }
    
    nonisolated public func navBarMaterial(@ViewBuilder view: @MainActor @escaping () -> some View) -> some View {
        modifier(NavBarMaterialModifier(view: view))
    }

    nonisolated public func navBarHidden(_ hidden: Bool = true) -> some View {
        preference(key: NavBarHiddenKey.self, value: hidden)
    }

}


extension View {
    
    nonisolated func navBarItemsRemoved(_ removed: Bool = true) -> some View {
        preferenceKeyReset(PresentationKey<NavBarItemMetadata>.self, reset: removed)
    }
    
    nonisolated func navBarRemoved(_ removed: Bool = true) -> some View {
        preferenceKeyReset(NavBarHiddenKey.self, reset: removed)
            .preferenceKeyReset(PresentationKey<NavBarItemMetadata>.self, reset: removed)
    }
    
}

struct NavBarPresenter<Label: View> {
    
    @State private var isPresented: Bool = true
    
    let meta: NavBarItemMetadata
    let label: @MainActor () -> Label
    
}


extension NavBarPresenter : ViewModifier {
    
    func body(content: Content) -> some View {
        content.presentationValue(
            isPresented: $isPresented,
            metadata: meta,
            content: label
        )
    }
    
}
