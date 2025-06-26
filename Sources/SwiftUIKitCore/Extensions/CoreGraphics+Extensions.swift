import SwiftUI


extension CGAffineTransform : EmptyInitalizable {}
extension CGPoint : EmptyInitalizable {}
extension CGSize : EmptyInitalizable {}
extension CGRect : EmptyInitalizable {}
extension CGFloat : EmptyInitalizable {}

public extension CGSize {
    
    func dimension(for axis: Axis) -> CGFloat {
       self[axis]
    }
    
    /// Calls rounded on both `width` and `height` of the size.
    /// - Parameter rule: The rounding rule to use for both `width` and `height`.
    /// - Returns: A `CGSize` with `width` and `height` rounded.
    func rounded(_ rule: FloatingPointRoundingRule) -> CGSize {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
    
    func fits(_ size: CGSize) -> Bool {
        width >= size.width && height >= size.height
    }
    
    func round(to place: CGFloat) -> CGSize {
        CGSizeMake(width.round(to: place), height.round(to: place))
    }
        
    init<F: BinaryFloatingPoint>(_ simd: SIMD2<F>) {
        self.init(width: Double(simd.x), height: Double(simd.y))
    }
    
    init(_ point: CGPoint) {
        self.init(width: point.x, height: point.y)
    }
    
    var smallestAxis: Axis {
        width < height ? .horizontal : .vertical
    }
    
    var largestAxis: Axis {
        width > height ? .horizontal : .vertical
    }
    
    subscript(_ axis: Axis) -> CGFloat {
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
    
    func scaleFitting(_ other: Self) -> Double {
        scaleOfFitting(self, in: other)
    }
    
    func rectByFitting(in other: CGSize) -> CGRect {
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
    
}

public func scaleOfFitting(_ size: CGSize, in other: CGSize) -> Double {
    let widthRatio = size.width / other.width
    let heightRatio = size.height / other.height
    return min(widthRatio, heightRatio)
}


public extension SIMD2 where Scalar == Float {
    
    @inlinable init(_ point: CGPoint) {
        self.init(Float(point.x), Float(point.y))
    }
    
}

public extension CGPoint {
    
    /// Calls rounded on both `x` and `y` of the point.
    /// - Parameter rule: The rounding rule to use for both `x` and `y`.
    /// - Returns: A `CGPoint` with `x` and `y` rounded.
    nonisolated func rounded(_ rule: FloatingPointRoundingRule) -> CGPoint {
        CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
    
    nonisolated func distance(to point: CGPoint) -> CGFloat {
        hypot(x - point.x, y - point.y)
    }
    
    nonisolated func distance(from rect: CGRect) -> CGFloat {
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
    
    func translate(by point: CGPoint) -> CGPoint {
        .init(x: x + point.x, y: y + point.y)
    }
    
    prefix static func -(point: CGPoint) -> CGPoint {
        .init(x: -point.x, y: -point.y)
    }
    
    @inlinable init<F: BinaryFloatingPoint>(_ simd: SIMD2<F>){
        self.init(x: Double(simd.x), y: Double(simd.y))
    }
    
    init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
    
    var smallestAxis: Axis {
        x < y ? .horizontal : .vertical
    }
    
    var largestAxis: Axis {
        x > y ? .horizontal : .vertical
    }
    
    subscript(_ axis: Axis) -> CGFloat {
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
    
}


public extension CGRect {
    
    /// Calls rounded on both `origin` and `size` of the rect.
    /// - Parameter rule: The rounding rule to use for both `origin` and `size`.
    /// - Returns: A `CGRect` with `origin` and `size` rounded.
    func rounded(_ rule: FloatingPointRoundingRule) -> CGRect {
        CGRect(origin: origin.rounded(rule), size: size.rounded(rule))
    }
    
    func normalizedDimension(for edge: Edge, in container: CGSize) -> CGFloat {
        switch edge {
        case .top: origin.y
        case .leading: origin.x
        case .bottom: (container.height - height) - origin.y
        case .trailing: (container.width - width) - origin.x
        }
    }
    
    func min(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: minX
        case .vertical: minY
        }
    }
      
    func mid(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: midX
        case .vertical: midY
        }
    }
    
    func max(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: maxX
        case .vertical: maxY
        }
    }
    
    func inset(_ insets: EdgeInsets) -> CGRect {
        CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
}


extension CGRect: @retroactive CustomStringConvertible {
    
    public var description: String {
        "\(origin.x),\(origin.y),\(size.width),\(size.height)"
    }
    
}

extension CGRect: @retroactive LosslessStringConvertible {
    
    public init?(_ description: String) {
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
    
    public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGPoint {
        CGPoint(
            x: x.replace(key, with: replacement),
            y: y.replace(key, with: replacement)
        )
    }
    
}


extension CGSize : ReplaceWhenFloatKeyIsTrueConformance {
    
    public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGSize {
        CGSize(
            width: width.replace(key, with: replacement),
            height: height.replace(key, with: replacement)
        )
    }
    
}


extension CGRect : ReplaceWhenFloatKeyIsTrueConformance {

    public func replace(_ key: KeyPath<CGFloat, Bool>, with replacement: CGFloat) -> CGRect {
        CGRect(
            origin: origin.replace(key, with: replacement),
            size: size.replace(key, with: replacement)
        )
    }
    
}
