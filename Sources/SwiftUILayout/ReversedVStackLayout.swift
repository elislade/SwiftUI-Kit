import SwiftUI

/// A vertical container that you can use in conditional layouts.
///
/// This layout container behaves like a ``VStackLayout``, but layout happens from bottom-to-top instead of top-to-bottom.
public struct ReversedVStackLayout: Layout, Sendable {
    
    public static let layoutProperties: LayoutProperties = {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }()

    /// The horizontal alignment of subviews.
    public var alignment: HorizontalAlignment
    
    /// The distance between adjacent subviews.
    ///
    /// Set this value to `nil` to use default distances between subviews.
    public var spacing: CGFloat?
    
    /// Creates a vertical stack with the specified spacing and horizontal
    /// alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. It has the same horizontal screen coordinate for all subviews.
    ///   - spacing: The distance between adjacent subviews. Set this value to `nil` to use default distances between subviews.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil
    ) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(
            width: subviews.reduce(into: 0){
                let width = $1.dimensions(in: proposal).width
                if width > $0 { $0 = width }
            },
            height: min(subviews.indices.reduce(into: 0.0){ total, i in
                total += subviews[i].dimensions(in: proposal).height
                if subviews.indices.contains(i + 1) {
                    if let spacing {
                        total += spacing
                    } else {
                        total += subviews[i].spacing.distance(to: subviews[i + 1].spacing, along: .vertical)
                    }
                }
            }, proposal.height ?? .infinity)
        )
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let bx = alignment == .center ? bounds.midX : alignment == .trailing ? bounds.maxX : bounds.minX
        var y: CGFloat = bounds.maxY
        let spacings:[CGFloat] = subviews.indices.map{ i in
            let otherIDX = i - 1
            if subviews.indices.contains(otherIDX) {
                if let spacing {
                    return spacing
                } else {
                    return subviews[i].spacing.distance(to: subviews[otherIDX].spacing, along: .vertical)
                }
            } else {
                return 0
            }
        }
        
        let maxHeight = (bounds.height - spacings.reduce(0, +)) /  CGFloat(subviews.count)
        
        for i in subviews.indices {
            let view = subviews[i]
            let dimension = view.dimensions(in: proposal)
            let height =  min(dimension.height, maxHeight)
            let x = alignment == .center ? bx - dimension.width / 2 : alignment == .leading ? bx : bx - dimension.width
            y -= height + spacings[i]
            view.place(at: .init(x: x, y: y), proposal: .init(width: dimension.width, height: height))
        }
    }
    
}
