import SwiftUI


public struct BasicToAnchorAdaptor: Adaptable {
    
    public init(){}
    
    public func adapt(_ value: BasicPresentationMetadata) -> AnchorPresentationMetadata {
        .init(
            sortDate: Date(),
            type: .vertical(preferredAlignment: .center),
            alignmentMode: .keepUntilInvalid,
            isLeader: false
        )
    }
    
}

extension Adaptable where Self == BasicToAnchorAdaptor {
    
    public static var basicToAnchor: Self { .init() }
    
}
