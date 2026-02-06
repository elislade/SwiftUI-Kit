import SwiftUI


public protocol DimensionedAnimationProvider {
    
    nonisolated func animation(for dimension: Double) -> Animation
    
}

extension DimensionedAnimationProvider {
    
    nonisolated public func callAsFunction(_ dimension: Double) -> Animation {
        animation(for: dimension)
    }
    
}


extension Animation: DimensionedAnimationProvider {
    
    nonisolated public func animation(for dimension: Double) -> Animation { self }
    
}


public struct DynamicDimensionedAnimationProvider: DimensionedAnimationProvider {
    
    let closure: (Double) -> Animation
    
    init(closure: @escaping (Double) -> Animation) {
        self.closure = closure
    }
    
    nonisolated public func animation(for dimension: Double) -> Animation {
        closure(dimension)
    }
    
}

extension DimensionedAnimationProvider where Self == DynamicDimensionedAnimationProvider {
    
    static nonisolated public func dynamic(closure: @escaping (_ dimension: Double) -> Animation) -> Self {
        .init(closure: closure)
    }
    
}
