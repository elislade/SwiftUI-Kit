import SwiftUI


extension Transform : Animatable {
    
    public typealias Scale = AnimatablePair<Double, Double>
    public typealias Translate = AnimatablePair<Double, Double>
    public typealias Shear = AnimatablePair<Double, Double>
    public typealias RotShear = AnimatablePair<Double, Shear>
    public typealias ScaleTranslate = AnimatablePair<Scale, Translate>
    
    public typealias AnimatableData = AnimatablePair<ScaleTranslate, RotShear>
    
    nonisolated public var animatableData: AnimatableData {
        get {
            AnimatableData(
                ScaleTranslate(
                    Scale(scale.x, scale.y), Translate(translation.x, translation.y)
                ),
                RotShear(rotation.radians, Shear(shear.x, shear.y))
            )
        }
        set {
            let scale = newValue.first.first, translate = newValue.first.second
            self.scale = .init(scale.first, scale.second)
            self.translation  = .init(translate.first, translate.second)
            
            self.rotation.radians = newValue.second.first
            self.shear = .init(newValue.second.second.first, newValue.second.second.second)
        }
    }
    
}
