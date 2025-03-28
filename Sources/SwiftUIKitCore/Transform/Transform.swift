import SwiftUI


public struct Transform: Hashable, Sendable {
    
    public enum Component: Hashable, CaseIterable, Sendable {
        case translation
        case scale
        case rotation
        case shear
    }
    
    public typealias Radian = Double
    public static let identity = Transform()
    
    public var rotation: Angle
    public var translation: SIMD2<Double>
    public var scale: SIMD2<Double>
    public var shear: SIMD2<Radian>
    
    public nonisolated init(
        rotation: Angle = .zero,
        translation: SIMD2<Double> = .zero,
        scale: SIMD2<Double> = .init(1, 1),
        shear: SIMD2<Radian> = .init(0, 0)
    ) {
        self.rotation = rotation
        self.translation = translation
        self.scale = scale
        self.shear = shear
    }
    
}


public extension View {
    
    nonisolated func transform(_ transform: Transform, orderMask: [Transform.Component] = Transform.Component.allCases) -> some View {
        modifier(TransformModifier(transform: transform, orderMask: orderMask))
    }
    
}
