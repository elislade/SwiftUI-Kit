import SwiftUI
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
    
    func navBarTitle(_ title: String) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .title)
        ){
            Text(title)
        }
    }
    
    func navBarTitle<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .title),
            content: view
        )
    }
    
    func navBarLeading<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .leading),
            content: view
        )
    }
    
    func navBarTrailing<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .trailing),
            content: view
        )
    }
    
    func navBarAccessory<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .accessory),
            content: view
        )
    }
    
    func navBarMaterial<V: View>(@ViewBuilder view: @escaping () -> V) -> some View {
        modifier(NavBarMaterialModifier(view: view))
    }

    func navBarHidden(_ bool: Bool) -> some View {
        preference(key: NavBarHiddenKey.self, value: bool)
    }

}


extension View {
    
    func disableNavBarPreferences(_ disabled: Bool = true) -> some View {
        resetPreference(NavBarHiddenKey.self, reset: disabled)
            .resetPreference(PresentationKey<NavBarItemMetadata>.self, reset: disabled)
    }
    
}
