import SwiftUI


extension Transform : Animatable {
    
    public typealias Scale = SIMD2<Double>.AnimatableData
    public typealias Translate = SIMD2<Double>.AnimatableData
    public typealias Shear = SIMD2<Double>.AnimatableData
    public typealias RotShear = AnimatablePair<Double, Shear>
    public typealias ScaleTranslate = AnimatablePair<Scale, Translate>
    
    public typealias AnimatableData = AnimatablePair<ScaleTranslate, RotShear>
    
    nonisolated public var animatableData: AnimatableData {
        get {
            AnimatableData(
                ScaleTranslate(
                    scale.animatableData, translation.animatableData
                ),
                RotShear(rotation.radians, shear.animatableData)
            )
        }
        set {
            self.scale.animatableData = newValue.first.first
            self.translation.animatableData  = newValue.first.second
            self.rotation.radians = newValue.second.first
            self.shear.animatableData = newValue.second.second
        }
    }
    
}
