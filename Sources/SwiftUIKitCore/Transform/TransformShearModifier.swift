import SwiftUI


struct TransformShearModifier: ViewModifier & Animatable {
    
    var shearX: Double
    var shearY: Double
    
    public typealias AnimatableValue = AnimatablePair<Double, Double>
    
    nonisolated public var animatableData: AnimatableValue {
        get { .init(shearX, shearY) }
        set { shearX = newValue.first; shearY = newValue.second }
    }
    
    func body(content: Content) -> some View {
        content.transformEffect(.init(shearX: shearX, shearY: shearY))
    }
    
}



public extension View {
    
    func shearHorizontal(_ angle: Angle) -> some View {
        modifier(TransformShearModifier(shearX: 0, shearY: angle.radians))
    }
    
    func shearVertical(_ angle: Angle) -> some View {
        modifier(TransformShearModifier(shearX: angle.radians, shearY: 0))
    }
    
}
