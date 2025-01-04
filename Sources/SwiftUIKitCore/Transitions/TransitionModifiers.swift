import SwiftUI


struct OpacityModifier:  ViewModifier, Hashable {
    
    let value: Double
    
    nonisolated init(value: Double = 0) {
        self.value = value
    }
    
    func body(content: Content) -> some View {
        content.opacity(value)
    }
    
}

struct OffsetModifier: ViewModifier, Hashable, Animatable {
    
    var offset: SIMD2<Double>
    
    public typealias AnimatableData = AnimatablePair<Double, Double>
    
    public nonisolated var animatableData: AnimatableData {
        get {
            AnimatableData(offset.x, offset.y)
        } set {
            offset.x = newValue.first
            offset.y = newValue.second
        }
    }
    
    nonisolated init(offset: SIMD2<Double> = .zero) {
        self.offset = offset
    }
    
    func body(content: Content) -> some View {
        content.offset(x: offset.x, y: offset.y)
    }
    
}

struct BlurModifier: ViewModifier, Hashable {
    
    let radius: Double
    let opaque: Bool
    
    nonisolated init(radius: Double = 0, opaque: Bool = false) {
        self.radius = radius
        self.opaque = opaque
    }
    
    func body(content: Content) -> some View {
        content.blur(radius: radius, opaque: opaque)
    }
    
}


struct ClipShapeModifier<S: Shape>: ViewModifier {
    
    let shape: S
    let style: FillStyle
    
    nonisolated init(shape: S, style: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content.clipShape(shape, style: style)
    }
    
}


struct ScaleModifier: ViewModifier, Hashable {
    
    let x: Double
    let y: Double
    let anchor: UnitPoint
    
    nonisolated init(x: Double = 1, y: Double = 1, anchor: UnitPoint = .center) {
        self.x = x
        self.y = y
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content.scaleEffect(x: x, y: y, anchor: anchor)
    }
    
}


struct RotationModifier: ViewModifier, Hashable {
    
    let angle: Angle
    let anchor: UnitPoint
    
    nonisolated init(angle: Angle = .zero, anchor: UnitPoint = .center) {
        self.angle = angle
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content.rotationEffect(angle, anchor: anchor)
    }
    
}


public struct Axis3D: Hashable, Sendable, Codable {
    
    public typealias Tuple = (x: CGFloat, y: CGFloat, z: CGFloat)
    
    public let x: Double
    public let y: Double
    public let z: Double
    
    public init(x: Double = 0, y: Double = 0, z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(_ tuple: Tuple) {
        self.x = tuple.x
        self.y = tuple.y
        self.z = tuple.z
    }
    
    public var tuple: Tuple { (x,y,z) }
    
    public static let x: Axis3D = Axis3D(x: 1, y: 0, z: 0)
    public static let y: Axis3D = Axis3D(x: 0, y: 1, z: 0)
    public static let z: Axis3D = Axis3D(x: 0, y: 0, z: 1)
    
    public static func + (lhs: Axis3D, rhs: Axis3D) -> Axis3D {
        Axis3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func - (lhs: Axis3D, rhs: Axis3D) -> Axis3D {
        Axis3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func * (lhs: Axis3D, rhs: Axis3D) -> Axis3D {
        Axis3D(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
}


struct Rotation3DModifier: ViewModifier, Hashable {
    
    let angle: Angle
    let axis: Axis3D
    let anchor: UnitPoint
    let depth: Double
    
    nonisolated init(
        angle: Angle = .zero,
        axis: Axis3D = .x,
        anchor: UnitPoint = .center,
        depth: Double = 0
    ) {
        self.angle = angle
        self.axis = axis
        self.anchor = anchor
        self.depth = depth
    }
    
    func body(content: Content) -> some View {
        content.rotation3DEffect(
            angle,
            axis: axis.tuple,
            anchor: anchor,
            anchorZ: depth,
            perspective: 0.8
        )
    }
    
}


struct GrayscaleModifier: ViewModifier, Hashable {
    
    let amount: Double
    
    nonisolated init(amount: Double = 0) {
        self.amount = amount
    }
    
    func body(content: Content) -> some View {
        content.grayscale(amount)
    }
    
}


struct HueRotationModifier: ViewModifier, Hashable {
    
    let angle: Angle
    
    nonisolated init(angle: Angle = .zero) {
        self.angle = angle
    }
    
    func body(content: Content) -> some View {
        content.hueRotation(angle)
    }
    
}


struct FrameModifier: ViewModifier {
    
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment
    
    nonisolated init(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment)
    }
    
}


struct ZIndexModifier: ViewModifier, Hashable {
    
    let index: Double
    
    nonisolated init(index: Double = 0) {
        self.index = index
    }
    
    func body(content: Content) -> some View {
        content.zIndex(index)
    }
    
}
