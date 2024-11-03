import SwiftUI

public struct PercentageRoundedRectangle: InsettableShape {
    
    let axis: Axis
    let range: Range<CGFloat>?
    
    var inset: CGFloat = 0
    var percentage: Double
    
    public var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(inset, percentage) }
        set {
            inset = newValue.first
            percentage = newValue.second
        }
    }
    
    public init(_ axis: Axis, percentage: Double, in range: Range<CGFloat>? = nil) {
        self.axis = axis
        self.percentage = percentage
        self.range = range
    }
    
    public func path(in rect: CGRect) -> Path {
        var value = (axis == .horizontal ? rect.width : rect.height) * percentage
        if let range {
            value = min(max(value, range.lowerBound), range.upperBound)
        }
        
        return RoundedRectangle(cornerRadius: value / 2)
            .inset(by: inset)
            .path(in: rect)
    }
    
    
    public func inset(by amount: CGFloat) -> PercentageRoundedRectangle {
        var copy = self
        copy.inset += amount
        return copy
    }
    
}
