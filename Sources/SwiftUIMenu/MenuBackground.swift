import SwiftUI

struct MenuBackgroundKey: EnvironmentKey {
    static var defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    
    var menuBackground: AnyView? {
        get { self[MenuBackgroundKey.self] }
        set { self[MenuBackgroundKey.self] = newValue }
    }
    
}

public extension View {
    
    func menuBackground<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        environment(\.menuBackground, AnyView(ZStack(content: content)))
    }
    
}
