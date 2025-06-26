import SwiftUI


public typealias AnimatableTwin<V: VectorArithmetic> = AnimatablePair<V, V>
public typealias AnimatableTriplet<V: VectorArithmetic> = AnimatablePair<AnimatableTwin<V>, V>
public typealias AnimatableQuadruplet<V: VectorArithmetic> = AnimatableTwin<AnimatableTwin<V>>
