import SwiftUI


extension SIMD2: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatablePair<Scalar, Scalar> {
        get { AnimatablePair(x, y) }
        set {
            x = newValue.first
            y = newValue.second
        }
    }
    
}


extension SIMD3: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatablePair<Scalar, AnimatablePair<Scalar, Scalar>> {
        get { AnimatablePair(x, AnimatablePair(y, z)) }
        set {
            self = [newValue.first, newValue.second.first, newValue.second.second]
        }
    }
    
}


extension SIMD4: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatablePair<AnimatablePair<Scalar, Scalar>, AnimatablePair<Scalar, Scalar>> {
        get { AnimatablePair(AnimatablePair(x, y), AnimatablePair(z, w)) }
        set {
            self = [
                newValue.first.first, newValue.first.second,
                newValue.second.first, newValue.second.second
            ]
        }
    }
    
}
