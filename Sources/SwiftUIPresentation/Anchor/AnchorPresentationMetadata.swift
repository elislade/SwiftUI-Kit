import SwiftUI

struct AnchorPresentationMetadata: Hashable, @unchecked Sendable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.anchorMode == rhs.anchorMode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(anchorMode)
    }
    
    enum AnchorMode: Hashable, Sendable {
        case auto
        case manual(source: UnitPoint, presentation: UnitPoint)
    }
    
    let anchorMode: AnchorMode
    let view: @MainActor (AutoAnchorState) -> AnyView
    
    func translate() -> BasicPresentationMetadata {
        .init(alignment: .bottom)
    }
    
}


extension BasicPresentationMetadata {
    
    init(translating: AnchorPresentationMetadata) {
        self.init(alignment: .center)
    }
    
}

public struct AutoAnchorState: Hashable, Sendable {
    public let anchor: UnitPoint
    public let edge: Edge
    
    public init(anchor: UnitPoint, edge: Edge) {
        self.anchor = anchor
        self.edge = edge
    }
}
