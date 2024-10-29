import SwiftUI

public enum StickyGrouping: UInt8, Hashable, CaseIterable, Codable, Sendable {
    
    /// Sticky bounds will not take into account already sticked item[s] along same edge.
    case none
    
    /// Sticky bounds are relative to already sticked item[s] along same edge.
    case stacked
    
    /// Sticky bounds will push the previous sticked item[s] along same edge and take their spot.
    case displaced
    
}


public struct StickingState: Equatable, Sendable {
    
    /// A set of edges that are currently sticking.
    /// - Note: This will usually be a single edge, but can be more. If the edge set is empty the view is **NOT**  sticking.
    public let stickingEdges: Edge.Set
    
    /// The horizontal grouping applied if this view is sticking with others.
    public let horizontalGrouping: StickyGrouping
    
    /// The vertical grouping applied if this view is sticking with others.
    public let verticalGrouping: StickyGrouping
    
    /// A computed bool indicating if this view has any vertical or horizontal grouping applied.
    public var isGrouping: Bool {
        horizontalGrouping != .none || verticalGrouping != .none
    }
    
    /// A computed bool indicating if this view is sticking on any edge.
    public var isSticking: Bool {
        stickingEdges.isEmpty == false
    }
    
    internal init(
        stickingEdges: Edge.Set = [],
        horizontalGrouping: StickyGrouping = .none,
        verticalGrouping: StickyGrouping = .none
    ) {
        self.stickingEdges = stickingEdges
        self.horizontalGrouping = horizontalGrouping
        self.verticalGrouping = verticalGrouping
    }
    
}


struct StickyPreferenceValue: Equatable {
    
    static func == (lhs: StickyPreferenceValue, rhs: StickyPreferenceValue) -> Bool {
        let bh = lhs.grouping == rhs.grouping
        let fb = lhs.anchor == rhs.anchor
        return lhs.id == rhs.id && lhs.insets == rhs.insets && bh && fb
    }
    
    let id: UUID
    let insets: OptionalEdgeInsets
    let categoryMask: StickyCategoryMask
    let grouping: StickyGrouping?
    let anchor: Anchor<CGRect>
    let update: (CGPoint, StickingState) -> Void
    
    
    /// A convienence property used by ``StickyContext`` to easily associate the resolved frame with this preferences anchor
    var resolvedFrame: CGRect = .zero
}


public struct StickyCategoryMask: OptionSet {
    
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
    public static let none = StickyCategoryMask([])
    
}
