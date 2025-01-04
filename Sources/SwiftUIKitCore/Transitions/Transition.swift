import SwiftUI

public extension AnyTransition {
    
    static func merge(_ collection: AnyTransition...) -> AnyTransition  {
        collection.merged()
    }
    
    static func merge<C: Collection>(_ collection: C) -> AnyTransition where C.Element == AnyTransition {
        collection.merged()
    }
        
    static func moveFade(edge: Edge) -> AnyTransition {
        [.move(edge: edge), .opacity].merged()
    }
    
    static func insertion(_ transitions: AnyTransition...) -> AnyTransition {
        .asymmetric(insertion: .merge(transitions), removal: .identity)
    }
    
    static func removal(_ transitions: AnyTransition...) -> AnyTransition {
        .asymmetric(insertion: .identity, removal: .merge(transitions))
    }

    static func moveOffset(edge: Edge = .leading) -> AnyTransition {
        .merge(.move(edge: edge), .offset(x: edge == .leading ? -50 : 50))
    }
    
    static func opacity(_ value: Double = 0) -> AnyTransition {
        .modifier(
            active: OpacityModifier(value: value),
            identity: OpacityModifier(value: 1)
        )
    }
    
    static func blur(radius: Double = 40, opaque: Bool = false) -> AnyTransition {
        .modifier(
            active: BlurModifier(radius: radius, opaque: opaque),
            identity: BlurModifier(opaque: opaque)
        )
    }
    
    static func scale(_ amount: Double = 0, anchor: UnitPoint = .center) -> AnyTransition {
        .scale(scale: amount, anchor: anchor)
    }
    
    static func offset(_ simd: SIMD2<Double>) -> AnyTransition {
        .modifier(
            active: OffsetModifier(offset: simd),
            identity: OffsetModifier(offset: .zero)
        )
    }
    
    static func scale(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: ScaleModifier(x: x, y: y, anchor: anchor),
            identity: ScaleModifier(anchor: anchor)
        )
    }
    
    static func rotation(angle: Angle = .degrees(180), anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: RotationModifier(angle: angle, anchor: anchor),
            identity: RotationModifier(anchor: anchor)
        )
    }
    
    static func rotation3D(angle: Angle = .degrees(180), axis: Axis3D = .x, anchor: UnitPoint = .center, depth: Double = 0) -> AnyTransition {
        .modifier(
            active: Rotation3DModifier(angle: angle, axis: axis, anchor: anchor, depth: depth),
            identity: Rotation3DModifier(axis: axis, anchor: anchor)
        )
    }
    
    static var grayscale: AnyTransition { .grayscale() }
    
    static func grayscale(amount: Double = 1) -> AnyTransition {
        .modifier(
            active: GrayscaleModifier(amount: amount),
            identity: GrayscaleModifier()
        )
    }
    
    static func hue(rotation: Angle = .degrees(360)) -> AnyTransition {
        .modifier(
            active: HueRotationModifier(angle: rotation),
            identity: HueRotationModifier()
        )
    }
    
    static func frame(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> AnyTransition {
        .modifier(
            active: FrameModifier(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment),
            identity: FrameModifier()
        )
    }
    
    static func zIndex(_ index: Double = 2) -> AnyTransition {
        .modifier(
            active: ZIndexModifier(index: index),
            identity: ZIndexModifier()
        )
    }
    
    static func clipRoundedRectangle(_ shape: RoundedRectangle) -> AnyTransition {
        .modifier(
            active: ClipShapeModifier(shape: shape),
            identity: ClipShapeModifier(shape: RoundedRectangle(cornerRadius: 0))
        )
    }
    
}


public extension View {
    
    func transitions(_ collection: AnyTransition...) -> some View  {
        transition(.merge(collection))
    }
    
    func transitions<C: Collection>(_ collection: C) -> some View where C.Element == AnyTransition {
        transition(.merge(collection))
    }
    
}


public extension Collection where Element == AnyTransition {
    
    func merged() -> AnyTransition {
        guard !isEmpty else { return .identity }
        
        return reduce(into: AnyTransition.identity){ a, b in
            a = a.combined(with: b)
        }
    }
    
}


public func +(lhs: AnyTransition, rhs: AnyTransition) -> AnyTransition {
    lhs.combined(with: rhs)
}

