import SwiftUI
import SwiftUIPresentation



public struct NavBarMaterialModifier<V: View> : ViewModifier {
    
    @State private var id = UUID()
    @ViewBuilder let view: () -> V
    
    public func body(content: Content) -> some View {
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
    
    let id: UUID
    let view: @MainActor () -> AnyView
    
}
