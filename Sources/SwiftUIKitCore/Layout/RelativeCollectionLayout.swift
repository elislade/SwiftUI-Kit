import SwiftUI


@MainActor @preconcurrency public protocol RelativeCollectionLayoutModifier {
    
    typealias Content = AnyView
    associatedtype Body: View
    
    @ViewBuilder @MainActor @preconcurrency func layoutItem(_ content: Content, index: Int, count: Int) -> Body
}


public final class AnyRelativeCollectionLayoutModifier: RelativeCollectionLayoutModifier {
    
    private let base: any RelativeCollectionLayoutModifier
    
    public init(_ base: any RelativeCollectionLayoutModifier){
        self.base = base
    }
    
    public func layoutItem(_ content: Content, index: Int, count: Int) -> some View {
        AnyView(base.layoutItem(content, index: index, count: count))
    }
    
}
