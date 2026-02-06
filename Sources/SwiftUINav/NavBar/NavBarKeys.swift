import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation



struct NavBarMaterialModifier<V: View> : ViewModifier {
    
    @State private var id = UniqueID()
    @ViewBuilder let view: @MainActor () -> V
    
    func body(content: Content) -> some View {
        content.preference(
            key: NavBarMaterialKey.self,
            value: [.init(id: id, view: { AnyView(view()) })]
        )
    }
    
}

public extension EnvironmentValues {
    
    @Entry var isInNavBar: Bool = false
    
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


public struct NavBarMaterialKey: PreferenceKey {
    
    public static func reduce(value: inout [NavBarMaterialValue], nextValue: () -> [NavBarMaterialValue]) {
        value.append(contentsOf: nextValue())
    }
    
    public static var defaultValue: [NavBarMaterialValue] { [] }
}


public struct NavBarMaterialValue: Equatable, Sendable {
    
    public static func == (lhs: NavBarMaterialValue, rhs: NavBarMaterialValue) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UniqueID
    let view: @MainActor () -> AnyView
    
}
