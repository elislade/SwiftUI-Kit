import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public extension View {
    
    func navBar<V: View>(
        _ placement: NavBarItemMetadata.Placement,
        @ViewBuilder view: @MainActor @escaping () -> V
    ) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: placement),
            content: view
        )
    }
    
    func navBarTitle(_ text: Text) -> some View {
        navBar(.title){ text.font(.title2[.semibold]) }
    }
    
    func navBarTitle<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        navBar(.title, view: view)
    }
    
    func navBarLeading<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        navBar(.leading, view: view)
    }
    
    func navBarTrailing<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        navBar(.trailing, view: view)
    }
    
    func navBarAccessory<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        navBar(.accessory, view: view)
    }
    
    func navBarMaterial<V: View>(@ViewBuilder view: @escaping () -> V) -> some View {
        modifier(NavBarMaterialModifier(view: view))
    }

    func navBarHidden(_ bool: Bool) -> some View {
        preference(key: NavBarHiddenKey.self, value: bool)
    }

}


extension View {
    
    func disableNavBarItems(_ disabled: Bool = true) -> some View {
        resetPreference(PresentationKey<NavBarItemMetadata>.self, reset: disabled)
    }
    
    func disableNavBarPreferences(_ disabled: Bool = true) -> some View {
        resetPreference(NavBarHiddenKey.self, reset: disabled)
            .resetPreference(PresentationKey<NavBarItemMetadata>.self, reset: disabled)
    }
    
}
