import SwiftUI


extension CGAffineTransform : EmptyInitalizable {}
extension CGPoint : EmptyInitalizable {}
extension CGSize : EmptyInitalizable {}
extension CGRect : EmptyInitalizable {}
extension CGFloat : EmptyInitalizable {}

extension CGSize {
    
    nonisolated public func dimension(for axis: Axis) -> CGFloat {
       self[axis]
    }
    
    /// Calls rounded on both `width` and `height` of the size.
    /// - Parameter rule: The rounding rule to use for both `width` and `height`.
    /// - Returns: A `CGSize` with `width` and `height` rounded.
    nonisolated public func rounded(_ rule: FloatingPointRoundingRule) -> CGSize {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
    
    nonisolated public func fits(_ size: CGSize) -> Bool {
        width >= size.width && height >= size.height
    }
    
    nonisolated public func round(to place: CGFloat) -> CGSize {
        CGSizeMake(width.round(to: place), height.round(to: place))
    }
        
    nonisolated public init<F: BinaryFloatingPoint>(_ simd: SIMD2<F>) {
        self.init(width: Double(simd.x), height: Double(simd.y))
    }
    
    nonisolated public init(_ point: CGPoint) {
        self.init(width: point.x, height: point.y)
    }
    
    nonisolated public var smallestAxis: Axis {
        width < height ? .horizontal : .vertical
    }
    
    nonisolated public var largestAxis: Axis {
        width > height ? .horizontal : .vertical
    }
    
    nonisolated public subscript(_ axis: Axis) -> CGFloat {
        get {
            switch axis {
            case .horizontal: width
            case .vertical: height
            }
        } set {
            switch axis {
            case .horizontal: width = newValue
            case .vertical: height = newValue
            }
        }
    }
    
    nonisolated public func scaleFitting(_ other: Self) -> Double {
        scaleOfFitting(self, in: other)
    }
    
    nonisolated public func rectByFitting(in other: CGSize) -> CGRect {
        let scale = scaleFitting(other)
        
        let scaledSize: SIMD2<Double> = [
            other.width * scale,
            other.height * scale
        ]
        
        let offset: SIMD2<Double> = [
            width - scaledSize.x,
            height - scaledSize.y
        ] / 2.0
        
        return CGRect(
            origin: .init(offset),
            size: .init(scaledSize)
        )
    }
    
    nonisolated public var simd: SIMD2<Double> { [width,height] }
    
}

nonisolated public func scaleOfFitting(_ size: CGSize, in other: CGSize) -> Double {
    let widthRatio = size.width / other.width
    let heightRatio = size.height / other.height
    return min(widthRatio, heightRatio)
}

nonisolated public func scaleOfFilling(_ size: CGSize, in other: CGSize) -> Double {
    let widthRatio = size.width / other.width
    let heightRatio = size.height / other.height
    return max(widthRatio, heightRatio)
}

extension SIMD2 where Scalar == Float {
    
    @inlinable nonisolated public init(_ point: CGPoint) {
        self.init(Float(point.x), Float(point.y))
    }
    
}

extension CGPoint {
    
    /// Calls rounded on both `x` and `y` of the point.
    /// - Parameter rule: The rounding rule to use for both `x` and `y`.
    /// - Returns: A `CGPoint` with `x` and `y` rounded.
    nonisolated public func rounded(_ rule: FloatingPointRoundingRule) -> CGPoint {
        CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
    
    nonisolated public func distance(to point: CGPoint) -> CGFloat {
        hypot(x - point.x, y - point.y)
    }
    
    nonisolated public func distance(from rect: CGRect) -> CGFloat {
        var vd: CGFloat = 0
        var hd: CGFloat = 0
        
        if y > rect.maxY {
            vd = y - rect.maxY
        } else if y < rect.minY {
            vd = rect.minY - y
        }
        
        if x > rect.maxX {
            hd = x - rect.maxX
        } else if x < rect.minX {
            hd = rect.minX - x
        }
        
        return max(vd, hd)
    }
    
    nonisolated public func translate(by point: CGPoint) -> CGPoint {
        .init(x: x + point.x, y: y + point.y)
    }
    
    prefix static nonisolated public func -(point: CGPoint) -> CGPoint {
        .init(x: -point.x, y: -point.y)
    }
    
    @inlinable nonisolated public init<F: BinaryFloatingPoint>(_ simd: SIMD2<F>){
        self.init(x: Double(simd.x), y: Double(simd.y))
    }
    
    nonisolated public init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
    
    nonisolated public var smallestAxis: Axis {
        x < y ? .horizontal : .vertical
    }
    
    nonisolated public var largestAxis: Axis {
        x > y ? .horizontal : .vertical
    }
    
    nonisolated public subscript(_ axis: Axis) -> CGFloat {
        get {
            switch axis {
            case .horizontal: x
            case .vertical: y
            }
        } set {
            switch axis {
            case .horizontal: x = newValue
            case .vertical: y = newValue
            }
        }
    }
    
    
    nonisolated public var simd: SIMD2<Double> { [x,y] }
    
}


extension CGRect {
    
    /// Calls rounded on both `origin` and `size` of the rect.
    /// - Parameter rule: The rounding rule to use for both `origin` and `size`.
    /// - Returns: A `CGRect` with `origin` and `size` rounded.
    nonisolated public func rounded(_ rule: FloatingPointRoundingRule) -> CGRect {
        CGRect(origin: origin.rounded(rule), size: size.rounded(rule))
    }
    
    nonisolated public func normalizedDimension(for edge: Edge, in container: CGSize) -> CGFloat {
        switch edge {
        case .top: origin.y
        case .leading: origin.x
        case .bottom: (container.height - height) - origin.y
        case .trailing: (container.width - width) - origin.x
        }
    }
    
    nonisolated public func min(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: minX
        case .vertical: minY
        }
    }
      
    nonisolated public func mid(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: midX
        case .vertical: midY
        }
    }
    
    nonisolated public func max(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: maxX
        case .vertical: maxY
        }
    }
    
    nonisolated public func inset(_ insets: EdgeInsets) -> CGRect {
        CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    nonisolated public var simd: SIMD4<Double> {
        [origin.x, origin.y, width, height]
    }
    
}


extension CGRect: @retroactive CustomStringConvertible {
    
    nonisolated public var description: String {
        "\(origin.x),\(origin.y),\(size.width),\(size.height)"
    }
    
}

extension CGRect: @retroactive LosslessStringConvertible {
    
    nonisolated public init?(_ description: String) {
        let comps = description.split(separator: ",").compactMap{
            $0.trimmingCharacters(in: .whitespaces)
        }.compactMap{
            Double(String($0))
        }
        
        guard comps.count == 4 else { return nil }
        self.init(x: comps[0], y: comps[1], width: comps[2], height: comps[3])
    }
    
}

extension CGAffineTransform: StaticIdentityConformance { }

extension CGFloat : ReplaceWhenFloatKeyIsTrueConformance {}

extension CGPoint : ReplaceWhenFloatKeyIsTrueConformance {
    
    nonisolated public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGPoint {
        CGPoint(
            x: x.replace(key, with: replacement),
            y: y.replace(key, with: replacement)
        )
    }
    
}


extension CGSize : ReplaceWhenFloatKeyIsTrueConformance {
    
    nonisolated public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGSize {
        CGSize(
            width: width.replace(key, with: replacement),
            height: height.replace(key, with: replacement)
        )
    }
    
}


extension CGRect : ReplaceWhenFloatKeyIsTrueConformance {

    nonisolated public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGRect {
        CGRect(
            origin: origin.replace(key, with: replacement),
            size: size.replace(key, with: replacement)
        )
    }
    
}


extension SIMD2 where Scalar: BinaryFloatingPoint {
    
    nonisolated public func invert(axis: Axis.Set) -> Self {
        self * [axis.contains(.horizontal) ? -1 : 1, axis.contains(.vertical) ? -1 : 1]
    }
    
    nonisolated public func zero(keeping axes: Axis.Set) -> Self {
        replacing(
            with: .zero,
            where: [!axes.contains(.horizontal), !axes.contains(.vertical)]
        )
    }
    
    nonisolated public var greatestMagnitudeAxis: Axis? {
        let x = abs(x), y = abs(y)
        return x > y ? .horizontal : y > x ? .vertical : nil
    }
    
}


extension SIMD2 where Scalar == Int {
    
    nonisolated public func invert(axis: Axis.Set) -> Self {
        self &* [axis.contains(.horizontal) ? -1 : 1, axis.contains(.vertical) ? -1 : 1]
    }
    
    nonisolated public func mask(axis: Axis.Set) -> Self {
        replacing(
            with: 0,
            where: [!axis.contains(.horizontal), !axis.contains(.vertical)]
        )
    }
    
    nonisolated public var greatestMagnitudeAxis: Axis? {
        let x = abs(x), y = abs(y)
        return x > y ? .horizontal : y > x ? .vertical : nil
    }
    
}


extension BinaryFloatingPoint {
    
    nonisolated public func moveAwayFromZero(to epsilon: Self) -> Self {
        (abs(self) < epsilon) ? (self >= .zero ? epsilon : -epsilon) : self
    }
    
}


extension SIMD where Scalar: BinaryFloatingPoint {
    
    nonisolated public func moveAwayFromZero(to epsilon: Scalar) -> Self {
        .init(indices.map{ self[$0].moveAwayFromZero(to: epsilon) })
    }
    
}


extension SIMD2: @retroactive ExpressibleByFloatLiteral where Scalar: BinaryFloatingPoint, FloatLiteralType == Scalar {

    nonisolated public init(floatLiteral value: Scalar) {
        self.init(x: value, y: value)
    }
    
}


extension CALayer {
    
    nonisolated public func enumerate(each: (CALayer) -> Bool) {
        guard let sublayers else { return }
        
        for layer in sublayers {
            let shouldStop = each(layer)
            if shouldStop { return }
        }
        
        for layer in sublayers {
            layer.enumerate(each: each)
        }
    }
    
}
