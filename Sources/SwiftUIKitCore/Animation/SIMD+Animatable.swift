import SwiftUI


extension SIMD2: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatableTwin<Scalar> {
        get { .init(x, y) }
        set {
            x = newValue.first
            y = newValue.second
        }
    }
    
}


extension SIMD3: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatableTriplet<Scalar> {
        get { .init(AnimatablePair(x, y), z) }
        set {
            x = newValue.first.first
            y = newValue.first.second
            z = newValue.second
        }
    }
    
}


extension SIMD4: @retroactive Animatable where Scalar: VectorArithmetic {
    
    public var animatableData: AnimatableQuadruplet<Scalar> {
        get { .init(AnimatablePair(x, y), AnimatablePair(z, w)) }
        set {
            x = newValue.first.first
            y = newValue.first.second
            z = newValue.second.first
            w = newValue.second.second
        }
    }
    
}
