import SwiftUI

struct FocusPresentationMetadata: Equatable {
    
    /// Stubbed true Equatable conformance will never update PresentationContext state on PreferenceKey Metadata changes
    /// This is to get around a Swift limitations discussed below.
    
    ///1.   Overload Resolution: When you provide multiple implementations of ==, Swift will always default to the unconstrained version (the less specific one), making it impossible to conditionally apply logic based on Equatable without manual intervention.
    ///2.   No Negative Constraints: Swift doesn’t support a way to say “Metadata is not Equatable” (negative conformance), which further complicates things when you’re trying to handle the non-Equatable case explicitly.
    ///3.   Runtime Type-Checking Limitations: While a runtime check like as? any Equatable seems like a possible solution, it fails because Swift doesn’t allow direct comparison of two values that conform to Equatable via type erasure.
    
    static func == (lhs: FocusPresentationMetadata, rhs: FocusPresentationMetadata) -> Bool {
        true
    }
    
    let sourceView: AnyView
    let accessory: (AutoAnchorState) -> AnyView?
    
}


extension PresentationValue where Metadata == BasicPresentationMetadata {
    
    init(_ value: PresentationValue<FocusPresentationMetadata>){
        self.init(other: value, metadata: .init(alignment: .bottom))
    }
    
}
