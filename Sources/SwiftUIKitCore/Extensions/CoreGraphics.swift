import SwiftUI


extension CGAffineTransform : EmptyInitalizable {}
extension CGPoint : EmptyInitalizable {}
extension CGSize : EmptyInitalizable {}
extension CGRect : EmptyInitalizable {}
extension CGFloat : EmptyInitalizable {}

public extension CGSize {
    
    func dimension(for axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: width
        case .vertical: height
        }
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
    
}

public extension CGPoint {
    
    /// Calls rounded on both `x` and `y` of the point.
    /// - Parameter rule: The rounding rule to use for both `x` and `y`.
    /// - Returns: A `CGPoint` with `x` and `y` rounded.
    nonisolated func rounded(_ rule: FloatingPointRoundingRule) -> CGPoint {
        CGPoint(x: x.rounded(rule), y: y.rounded(rule))
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
