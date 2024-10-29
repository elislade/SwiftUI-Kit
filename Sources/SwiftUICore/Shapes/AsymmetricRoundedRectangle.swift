import SwiftUI


public struct RadiusValues: Hashable, Animatable, Sendable {
    
    public static let zero = RadiusValues()
    
    public var topLeft: Double
    public var topRight: Double
    public var bottomLeft: Double
    public var bottomRight: Double
    
    
    /// Creates a new RadiusValues.
    /// - Parameters:
    ///   - topLeft: The radius of the top left corner. Defaults to 0.
    ///   - topRight: The radius of the top right corner. Defaults to 0.
    ///   - bottomRight: The radius of the bottom right corner. Defaults to 0.
    ///   - bottomLeft: The radius of the bottom left corner. Defaults to 0.
    public init(topLeft: Double = 0, topRight: Double = 0, bottomRight: Double = 0, bottomLeft: Double = 0) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    
    /// Creates a new RadiusValues
    /// - Parameters:
    ///   - top: The radius of the top corners. Defaults to 0.
    ///   - bottom: The radius of the bottom corners. Defaults to 0.
    public init(top: Double = 0, bottom: Double = 0) {
        self.init(topLeft: top, topRight: top, bottomRight: bottom, bottomLeft: bottom)
    }
    
    /// Creates a new RadiusValues.
    /// - Parameters:
    ///   - left: The radius of the left corners. Defaults to 0.
    ///   - right: The radius of the right corners. Defaults to 0.
    public init(left: Double = 0, right: Double = 0) {
        self.init(topLeft: left, topRight: right, bottomRight: right, bottomLeft: left)
    }
    
    
    ///  Creates a new RadiusValues.
    /// - Parameter value: The radius of all the corners. Defaults to 0.
    public init(_ value: Double = 0) {
        self.init(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
    }
    
    
    /// The type defining the top data to animate.
    public typealias AnimatableTop = AnimatablePair<Double, Double>
    
    /// The type defining the bottom data to animate.
    public typealias AnimatableBottom = AnimatablePair<Double, Double>
    
    /// The type defining the data to animate.
    public typealias AnimatableData = AnimatablePair<AnimatableTop, AnimatableBottom>
    
    /// The data to animate.
    public var animatableData: AnimatableData {
        get {
            let top = AnimatableTop(topLeft, topRight)
            let bottom = AnimatableBottom(bottomLeft, bottomRight)
            return AnimatableData(top, bottom)
        }
        set {
            let top = newValue.first
            let bottom = newValue.second
            topLeft = top.first
            topRight = top.second
            bottomLeft = bottom.first
            bottomRight = bottom.second
        }
    }
    
    public func values(for edge: Edge, clockwise: Bool = true) -> (Double, Double) {
        switch edge {
        case .top: clockwise ? (topLeft, topRight) : (topRight, topLeft)
        case .leading: clockwise ? (bottomLeft, topLeft) : (topLeft, bottomLeft)
        case .bottom: clockwise ? (bottomRight, bottomLeft) : (bottomLeft, bottomRight)
        case .trailing: clockwise ? (topRight, bottomRight) : (bottomRight, topRight)
        }
    }
    
    public static func + (lhs:  RadiusValues, value: Double) -> RadiusValues {
        var copy = lhs
        copy.topLeft += value
        copy.topRight += value
        copy.bottomLeft += value
        copy.bottomRight += value
        return copy
    }
    
    public static func - (lhs: RadiusValues, value: Double) -> RadiusValues {
        var copy = lhs
        copy.topLeft -= value
        copy.topRight -= value
        copy.bottomLeft -= value
        copy.bottomRight -= value
        return copy
    }
    
}


extension RadiusValues: LosslessStringConvertible {
    
    public init?(_ description: String) {
        let values = description
            .components(separatedBy: ",")
            .compactMap({ Double($0) })
        
        guard values.count == 4 else { return nil }
        
        self.init(
            topLeft: values[0], topRight: values[1],
            bottomRight: values[2], bottomLeft: values[3]
        )
    }
    
    public var description: String {
        "\(topLeft),\(topRight),\(bottomRight),\(bottomLeft)"
    }
    
}


/// A rectangular shape with rounded corners, aligned inside the frame of the
/// view containing it.
public struct AsymmetricRoundedRectangle: Shape {
    
    
    /// A touple of the asymmetric radius. Clockwise starting from topLeft.
    public var radius: RadiusValues
    
    private var insetRadius: RadiusValues { radius - inset }
    
    /// Amount to inset shape
    var inset: CGFloat = 0
    
    
    ///  Creates a new asymmetric rounded rectangle shape.
    ///
    /// - Parameter values: The radius of the top left corner. Defaults to `.zero`.
    public init(values: RadiusValues = .zero){
        self.radius = values
    }
    

    ///  Calculates scaled corner radi if they don't fit correctly in available size.
    ///
    /// - Parameter size: The available size of the shape.
    ///
    /// - Returns: A tuple of the asymmetric safe radius. Clockwise starting from topLeft.
    private func safeRadius(in size: CGSize) -> RadiusValues {
        let sides: [Edge] = [.top, .trailing, .bottom, .leading]
        let safeSides = sides.map { edge in
            let side = insetRadius.values(for: edge)
            let sideRadius = side.0 + side.1
            
            if Edge.Set.horizontal.contains(.init(edge)) {
                if sideRadius > size.width {
                    let scaleFactor = size.width / sideRadius
                    return (side.0 * scaleFactor, side.1 * scaleFactor)
                } else {
                    return side
                }
            } else {
                if sideRadius > size.height {
                    let scaleFactor = size.height / sideRadius
                    return (side.0 * scaleFactor, side.1 * scaleFactor)
                } else {
                    return side
                }
            }
        }
        
        return RadiusValues(
            topLeft: max(min(safeSides[0].0, safeSides[3].1), 0),
            topRight: max(min(safeSides[0].1, safeSides[1].0), 0),
            bottomRight: max(min(safeSides[1].1, safeSides[2].0), 0),
            bottomLeft: max(min(safeSides[2].1, safeSides[3].0), 0)
        )
    }
    
    
    /// Describes this shape as a path within a rectangular frame of reference.
    ///
    /// - Parameter rect: The frame of reference for describing this shape.
    ///
    /// - Returns: A path that describes this shape.
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        let radius = safeRadius(in: rect.size)
        return Path{ path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            if radius.topLeft > 0 {
                let center = CGPoint(
                    x: rect.minX + radius.topLeft,
                    y: rect.minY + radius.topLeft
                )
                path.addRelativeArc(
                    center: center,
                    radius: radius.topLeft,
                    startAngle: .degrees(-180),
                    delta: .degrees(90)
                )
            }
            
            path.addLine(to: CGPoint(
                x: rect.maxX,
                y: rect.minY
            ))
            
            if radius.topRight > 0 {
                let center = CGPoint(
                    x: rect.maxX - radius.topRight,
                    y: rect.minY + radius.topRight
                )
                path.addRelativeArc(
                    center: center,
                    radius: radius.topRight,
                    startAngle: .degrees(-90),
                    delta: .degrees(90)
                )
            }
            
            path.addLine(to: CGPoint(
                x: rect.maxX,
                y: rect.maxY - radius.bottomRight)
            )
            
            if radius.bottomRight > 0 {
                let center = CGPoint(
                    x: rect.maxX - radius.bottomRight,
                    y: rect.maxY - radius.bottomRight
                )
                path.addRelativeArc(
                    center: center,
                    radius: radius.bottomRight,
                    startAngle: .zero,
                    delta: .degrees(90)
                )
            }
            
            path.addLine(to: CGPoint(
                x: rect.minX,
                y: rect.maxY
            ))
            
            if radius.bottomLeft > 0 {
                let center = CGPoint(
                    x: rect.minX + radius.bottomLeft,
                    y: rect.maxY - radius.bottomLeft
                )
                path.addRelativeArc(
                    center: center,
                    radius: radius.bottomLeft,
                    startAngle: .degrees(90),
                    delta: .degrees(90)
                )
            }
            
            path.closeSubpath()
        }
    }
    
}


extension AsymmetricRoundedRectangle: Animatable {
    
    public typealias AnimatableData = AnimatablePair<RadiusValues.AnimatableData, CGFloat>
    
    /// The data to animate.
    public var animatableData: AnimatableData {
        get { .init(radius.animatableData, inset) }
        set {
            radius.animatableData = newValue.first
            inset = newValue.second
        }
    }
    
}


extension AsymmetricRoundedRectangle: InsettableShape {
    
    public func inset(by amount: CGFloat) -> AsymmetricRoundedRectangle {
        var copy = self
        copy.inset = amount
        return copy
    }
 
}
