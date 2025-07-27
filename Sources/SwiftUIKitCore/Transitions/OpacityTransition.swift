import SwiftUI


public extension AnyTransition {
    
    static func opacity(_ value: Double, identity: Double = 1) -> AnyTransition {
        .modifier(
            active: OpacityModifier(value: value),
            identity: OpacityModifier(value: identity)
        )
    }
    
}


struct OpacityModifier:  ViewModifier, Hashable {
    
    let value: Double
    
    nonisolated init(value: Double = 0) {
        self.value = value
    }
    
    func body(content: Content) -> some View {
        content.opacity(value)
    }
    
}
