import SwiftUI


public extension AnyTransition {
    
    static func opacity(_ value: Double = 0) -> AnyTransition {
        .modifier(
            active: OpacityModifier(value: value),
            identity: OpacityModifier(value: 1)
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
