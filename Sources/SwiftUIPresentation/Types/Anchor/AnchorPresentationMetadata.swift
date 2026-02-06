import SwiftUI

public struct AnchorPresentationMetadata: Equatable, Sendable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type
        && lhs.sortDate == rhs.sortDate
        && lhs.isLeader == rhs.isLeader
    }
    
    let sortDate: Date
    let type: PresentedAnchorType
    let alignmentMode: AnchorAlignmentMode
    let isLeader: Bool
    
    public init(sortDate: Date, type: PresentedAnchorType, alignmentMode: AnchorAlignmentMode, isLeader: Bool) {
        self.sortDate = sortDate
        self.type = type
        self.alignmentMode = alignmentMode
        self.isLeader = isLeader
    }
    
}

public enum AnchorAlignmentMode: Hashable, Sendable {
    case keepUntilInvalid
    case keepUntilPast(_ fraction: UnitPoint)
}

public struct AnchorState: Hashable, Sendable {
    
    public let source: UnitPoint
    public let presentation: UnitPoint
    
    nonisolated public var horizontalEdge: HorizontalEdge? {
        presentation.x == 0 && source.x == 1 ? .leading : presentation.x == 1 && source.x == 0 ? .trailing : nil
    }
    
    nonisolated public var verticalEdge: VerticalEdge? {
        presentation.y == 0 && source.y == 1 ? .top : presentation.y == 1 && source.y == 0 ? .bottom : nil
    }
    
    public init(_ source: UnitPoint, _ presentation: UnitPoint) {
        self.source = source
        self.presentation = presentation
    }
    
}


public enum PresentedAnchorType: Equatable, Sendable {
    
    /// Explicitly control how the anchor of source(view triggering the presentation) relates to the anchor of the destination(view that is being presented).
    /// - Note: This has no evaluation on layout safety.
    case explicit(source: UnitPoint, destination: UnitPoint)
    
    /// auto aligns the source and destination on the vertical axis depending on how they relate to eachother. PreferredAlignment will be used unless it breaks the layout, otherwise its auto determined. If neither option is layout safe then the preferred one will be picked.
    case vertical(preferredAlignment: HorizontalAlignment = .leading)
    
    /// auto aligns the source and destination on the horizontal axis depending on how they relate to eachother. PreferredAlignment will be used unless it breaks the layout otherwise its auto determined. If neither option is layout safe then the preferred one will be picked.
    case horizontal(preferredAlignment: VerticalAlignment = .top)
    
}


extension PresentedAnchorType {
    
    /// Conveinience for setting some explicit values for vertical edges. Edge referes to the edge the destination view will appear on, relative to the source.
    static nonisolated public func vertical(edge: VerticalEdge, alignment: HorizontalAlignment = .center) -> Self {
        .explicit(
            source: .init(x: alignment.descreteUnitValue ?? 0.5, y: edge == .bottom ? 1 : 0),
            destination: .init(x: alignment.descreteUnitValue ?? 0.5, y: edge == .bottom ? 0 : 1)
        )
    }
    
    /// Conveinience for setting some explicit values for horizontal edges. Edge referes to the edge the destination view will appear on, relative to the source.
    static nonisolated public func horizontal(edge: HorizontalEdge, alignment: VerticalAlignment = .center) -> Self {
        .explicit(
            source: .init(x: edge == .trailing ? 1 : 0, y: alignment.descreteUnitValue ?? 0.5),
            destination: .init(x: edge == .trailing ? 0 : 1, y: alignment.descreteUnitValue ?? 0.5)
        )
    }
    
}


extension HorizontalAlignment {
    
    nonisolated var descreteUnitValue: Double? {
        if self == .leading { 0 }
        else if self == .trailing { 1 }
        else if self == .center { 0.5 }
        else { nil }
    }
    
}

extension VerticalAlignment {
    
    nonisolated var descreteUnitValue: Double? {
        if self == .top { 0 }
        else if self == .bottom { 1 }
        else if self == .center { 0.5 }
        else { nil }
    }
    
}
