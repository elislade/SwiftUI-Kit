import SwiftUI


public struct AnchorToBasicAdaptor: Adaptable {
    
    public init(){}
    
    public func adapt(_ value: AnchorPresentationMetadata) -> BasicPresentationMetadata {
        .init(alignment: .bottom)
    }
    
}


extension Adaptable where Self == AnchorToBasicAdaptor {
    
    public static var anchorToBasic: Self { .init() }
    
}

