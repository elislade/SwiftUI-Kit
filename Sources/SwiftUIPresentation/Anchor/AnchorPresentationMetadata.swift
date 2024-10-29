import SwiftUI

struct AnchorPresentationMetadata: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.anchorMode == rhs.anchorMode
    }
    
    enum AnchorMode: Equatable {
        case auto
        case manual(source: UnitPoint, presentation: UnitPoint)
    }
    
    let anchorMode: AnchorMode
    let view: (AutoAnchorState) -> AnyView
    
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
