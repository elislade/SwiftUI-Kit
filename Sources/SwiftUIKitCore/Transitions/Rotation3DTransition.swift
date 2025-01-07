import SwiftUI


public extension AnyTransition {
    
    static func rotation3D(angle: Angle = .degrees(180), axis: Axis3D = .x, anchor: UnitPoint = .center, depth: Double = 0) -> AnyTransition {
        .modifier(
            active: Rotation3DModifier(angle: angle, axis: axis, anchor: anchor, depth: depth),
            identity: Rotation3DModifier(axis: axis, anchor: anchor)
        )
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
