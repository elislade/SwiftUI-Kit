import SwiftUI


public extension AnyTransition {
    
    static var grayscale: AnyTransition { .grayscale(amount: 1) }
    
    static func grayscale(amount: Double) -> AnyTransition {
        .modifier(
            active: GrayscaleModifier(amount: amount),
            identity: GrayscaleModifier()
        )
    }
    
}


struct GrayscaleModifier: ViewModifier, Hashable {
    
    let amount: Double
    
    nonisolated init(amount: Double = 0) {
        self.amount = amount
    }
    
    func body(content: Content) -> some View {
        content.grayscale(amount)
    }
    
}
