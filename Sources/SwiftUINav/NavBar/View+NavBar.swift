import SwiftUI
import SwiftUIPresentation


public extension View {
    
    
    /// A
    /// - Parameters:
    ///   - placement: A
    ///   - view: A
    /// - Returns: A
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
    
    
    /// A
    /// - Parameter title: A
    /// - Returns: A
    func navBarTitle(_ title: String) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .title)
        ){
            Text(title)
        }
    }
    
    
    /// Adds an titleview to the NavBar.
    /// - Parameter view: A
    /// - Returns: A
    func navBarTitle<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .title),
            content: view
        )
    }
    
    
    /// Adds an leading view to the NavBar.
    /// - Parameter view: A
    /// - Returns: A
    func navBarLeading<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .leading),
            content: view
        )
    }
    
    
    /// Adds an trailing view to the NavBar.
    /// - Parameter view: A
    /// - Returns: A
    func navBarTrailing<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .trailing),
            content: view
        )
    }
    
    
    /// Adds an accessory view to the NavBar.
    /// - Parameter view: A
    /// - Returns: A
    func navBarAccessory<V: View>(@ViewBuilder view: @MainActor @escaping () -> V) -> some View {
        presentationValue(
            isPresented: .constant(true),
            metadata: NavBarItemMetadata(placement: .accessory),
            content: view
        )
    }
    
    
    /// Replaces the NavBar background material.
    /// - Parameter view: A
    /// - Returns: A
    func navBarMaterial<V: View>(@ViewBuilder view: @escaping () -> V) -> some View {
        modifier(NavBarMaterialModifier(view: view))
    }
    
    
    /// Hides the nav bar.
    /// - Parameter bool: A
    /// - Returns: A
    func navBarHidden(_ bool: Bool) -> some View {
        preference(key: NavBarHiddenKey.self, value: bool)
    }

}


extension View {
    
    func disableNavBarPreferences(_ disabled: Bool = true) -> some View {
        self
            .transformPreference(NavBarHiddenKey.self){ value in if disabled { value = false } }
            .transformPreference(PresentationKey<NavBarItemMetadata>.self){ value in if disabled { value = [] } }
    }
    
}


struct NavBarMaterialModifier<V: View> : ViewModifier {
    
    @State private var id = UUID()
    let view: () -> V
    
    func body(content: Content) -> some View {
        content.preference(
            key: NavBarMaterialKey.self,
            value: [.init(id: .init(), view: { AnyView(view()) })]
        )
    }
    
}


struct IsInNavBarKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}

public extension EnvironmentValues {
    
    var isInNavBar: Bool {
        get { self[IsInNavBarKey.self] }
        set { self[IsInNavBarKey.self] = newValue }
    }
    
}


struct NavBarHiddenKey: PreferenceKey {
    
    static var defaultValue: Bool { false }
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        let next = nextValue()
        if next {
            value = next
        }
    }
    
}


struct NavBarMaterialKey: PreferenceKey {
    
    static func reduce(value: inout [NavBarMaterialValue], nextValue: () -> [NavBarMaterialValue]) {
        value.append(contentsOf: nextValue())
    }
    
    static var defaultValue: [NavBarMaterialValue] { [] }
}


struct NavBarMaterialValue: Equatable, Sendable {
    
    static func == (lhs: NavBarMaterialValue, rhs: NavBarMaterialValue) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let view: @MainActor () -> AnyView
    
}
