import SwiftUI


public struct PointedRect : Shape {
    
    var edge: Edge
    var cornerRadius: CGFloat
    var cornerStyle: RoundedCornerStyle
    var anchor: Double
    var inset: Double = 0
    
    public init(
        edge: Edge,
        cornerRadius: CGFloat,
        cornerStyle: RoundedCornerStyle = .circular,
        anchor: Double = 0.5
    ) {
        self.edge = edge
        self.cornerRadius = cornerRadius
        self.cornerStyle = cornerStyle
        self.anchor = anchor
    }
    
    nonisolated public func path(in rect: CGRect) -> Path {
        let pointHeight: Double = 15, pointWidth: Double = 24
        let pointRadius: CGFloat = 4.0
        let outerRadius = (pointRadius * 2) + inset
        let relativeHypotenuse = sqrt(pow(pointHeight / (pointWidth / 2), 2) + 1)
        let startA = CGPoint(x: -(30 + inset), y: -inset), startB = CGPoint(x: (0.48 * inset), y: -inset)
        let mid = CGPoint(x: pointWidth / 2, y: pointHeight - (inset * relativeHypotenuse))
        let endA = CGPoint(x: pointWidth - (0.48 * inset), y: -inset), endB = CGPoint(x: rect.maxX, y: -inset)
        
        guard
            let startArc = filletArc(from: startA, via: startB, to: mid, radius: outerRadius),
            let midArc = filletArc(from: startB, via: mid, to: endA, radius: pointRadius - inset),
            let endArc = filletArc(from: mid, via: endA, to: endB, radius: outerRadius)
        else {
            return Path{ _ in }
        }
            
        let point = Path { ctx in
            func add(_ arc: (
                p1: CGPoint, p2: CGPoint,
                center: CGPoint,
                startAngle: Angle, endAngle: Angle,
                clockwise: Bool
            )) {
                let dx = arc.p1.x - arc.center.x
                let dy = arc.p1.y - arc.center.y
                let effectiveRadius = sqrt(dx*dx + dy*dy)

                ctx.addArc(
                    center: arc.center,
                    radius: effectiveRadius,
                    startAngle: arc.startAngle,
                    endAngle: arc.endAngle,
                    clockwise: arc.clockwise
                )
            }
            
            add(startArc)
            add(midArc)
            add(endArc)
            
            ctx.closeSubpath()
        }
        
        let axis: Axis = edge == .bottom || edge == .top ? .horizontal : .vertical
        let smallestAxis = rect.size.smallestAxis
        let dimension = rect.size[axis]
        let resolvedPointWidth = endArc.p2.x - startArc.p1.x

        let ad = (dimension - resolvedPointWidth)
        
        let minRadius = smallestAxis == axis ?
            /* subtract pointWidth */ (dimension - resolvedPointWidth) / 2 :
            /* don't subtract pointWidth */ (rect.size[smallestAxis] / 2)
        
        let safeRadius = min(cornerRadius, max(minRadius, 0))
        let availableDimension = dimension - ((safeRadius * 2) + resolvedPointWidth)
        let left = availableDimension < 0 ? (ad / 2) : (availableDimension * anchor) + safeRadius
    
        let rectPath = RoundedRectangle(
            cornerRadius: safeRadius,
            style: cornerStyle
        ).inset(by: inset).path(in: rect)
        
        let edgeRounding = cornerStyle == .continuous ? 0.4 : 0.01
        
        let pathToUnion = switch edge {
        case .top:
            point
                .applying(
                    .identity
                    .translatedBy(x: -startArc.p1.x + left, y: edgeRounding)
                    .scaledBy(x: 1, y: -1)
                )
        case .leading:
            point
                .applying(
                    .identity
                    .translatedBy(x: 0, y: -startArc.p1.x)
                    .rotated(by: Angle.degrees(90).radians)
                    .concatenating(.init(translationX: edgeRounding, y: left))
                )
        case .bottom:
            point
                .applying(
                    .identity
                    .translatedBy(x: -startArc.p1.x + left, y: rect.height - edgeRounding)
                )
        case .trailing:
            point
                .applying(
                    .identity
                    .translatedBy(x: rect.width, y: -startArc.p1.x)
                    .scaledBy(x: -1, y: 1)
                    .rotated(by: Angle.degrees(90).radians)
                    .concatenating(.init(translationX: -edgeRounding, y: left))
                )
        }
        
        return Path(pathToUnion.cgPath.union(rectPath.cgPath))
    }
    
}


extension PointedRect : InsettableShape {
    
    public func inset(by amount: CGFloat) -> Self {
        var copy = self
        copy.inset += amount
        return copy
    }
    
}


extension PointedRect {
    
    nonisolated public var animatableData: AnimatableTwin<Double> {
        get { .init(anchor, inset) }
        set {
            anchor = newValue.first
            inset = newValue.second
        }
    }
    
}


func filletArc(
    from pointA: CGPoint,
    via pointB: CGPoint,
    to pointC: CGPoint,
    radius: CGFloat
) -> (
    p1: CGPoint, p2: CGPoint,
    center: CGPoint,
    startAngle: Angle, endAngle: Angle,
    clockwise: Bool
)? {
    
    let vectorAB = pointA.simd - pointB.simd, vectorBC = pointC.simd - pointB.simd
    let lengthAB = hypot(vectorAB.x, vectorAB.y), lengthBC = hypot(vectorBC.x, vectorBC.y)
    
    guard lengthAB > .ulpOfOne, lengthBC > .ulpOfOne else { return nil }
    
    let directionAB = -vectorAB / lengthAB, directionBC = vectorBC / lengthBC
    
    // Angle between -directionAB and directionBC
    let cosTheta = max(-1.0, min(1.0, (-directionAB.x * directionBC.x + -directionAB.y * directionBC.y)))
    let theta = acos(cosTheta)
    // If nearly straight or zero angle, no corner
    if theta.isNaN || theta < 1e-3 || abs(.pi - theta) < 1e-3 { return nil }
    
    // Clamp radius so it fits within both segments for this corner angle
    let epsilon: CGFloat = 1e-4
    let tanHalf = tan(theta / 2)
    // If tanHalf is ~0 (nearly straight), bail
    if abs(tanHalf) < 1e-6 { return nil }
    let radiusMax = min(lengthAB, lengthBC) * tanHalf
    let effectiveRadius = max(0, min(radius, radiusMax - epsilon))

    // Recompute trim distance with the effective radius
    let t = effectiveRadius / tanHalf
    
    // Tangent points
    let pointStart = CGPoint(
        x: pointB.x - directionAB.x * t,
        y: pointB.y - directionAB.y * t
    )
    
    let pointEnd = CGPoint(
        x: pointB.x + directionBC.x * t,
        y: pointB.y + directionBC.y * t
    )
    
    // Bisector directionAB
    let inwardDirectionAB = directionAB * -1
    let sum = inwardDirectionAB + directionBC
    let lenSum = hypot(sum.x, sum.y)
    guard lenSum > .ulpOfOne else { return nil }
    
    let w = sum / lenSum
    
    // Center distance along bisector
    let h = effectiveRadius / sin(theta / 2)
    let center = CGPoint(x: pointB.x + w.x * h, y: pointB.y + w.y * h)
    
    func radians(of p: CGPoint) -> CGFloat {
        atan2(p.y - center.y, p.x - center.x)
    }
    
    let startRadians = radians(of: pointStart)
    let endRadians = radians(of: pointEnd)
    
    // Determine clockwise based on turn orientation.
    // If cross > 0 => left turn; if cross < 0 => right turn.
    // In CoreGraphics, "clockwise: true" draws clockwise in the current coordinate system (y down).
    // For a standard screen coord system, a right turn typically needs clockwise = true.
    let cross = directionAB.x * directionBC.y - directionAB.y * directionBC.x
    
    return (
        pointStart, pointEnd,
        center,
        Angle(radians: startRadians), Angle(radians: endRadians),
        cross < 0
    )
}

extension RectangleCornerRadii {
    
    mutating func set(_ edge: Edge, _ value: CGFloat) {
        switch edge {
        case .top:
            topLeading = value
            topTrailing = value
        case .leading:
            topLeading = value
            bottomLeading = value
        case .bottom:
            bottomLeading = value
            bottomTrailing = value
        case .trailing:
            topTrailing = value
            bottomTrailing = value
        }
    }
    
}


func measuredSmoothRadius(for radius: CGFloat) -> CGFloat {
    let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
    let size = CGSizeMake(radius * 3, radius * 3)
    let path = shape.path(in: CGRect(origin: .zero, size: size))
    var maxInset: CGFloat = 0
    
    path.forEach { element in
        switch element {
        case .quadCurve(let end, _):
            // only use top edge so radii past 2x are not important
            if end.y < 2 * radius {
                maxInset = max(maxInset, end.y)
            }
        case .curve(let end, _, _):
            // only use top edge so radii past 2x are not important
            if end.y < 2 * radius {
                maxInset = max(maxInset, end.y)
            }
        default:
            break
        }
    }

    return maxInset
}

