import SwiftUI


struct TransformModifier: ViewModifier, Animatable {
    
    var transform: Transform
    let orderMask: [Transform.Component]
    
    nonisolated init(transform: Transform, orderMask: [Transform.Component]) {
        self.transform = transform
        self.orderMask = orderMask
    }
    
    nonisolated public var animatableData: Transform.AnimatableData {
        get { transform.animatableData }
        set {
            transform.animatableData = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .transformEffect(transform[orderMask])
    }
    
}
