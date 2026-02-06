import SwiftUI


public struct AnyInsettableShape: InsettableShape {
    
    let shape: any InsettableShape
    
    nonisolated public init(_ shape: some InsettableShape) {
        self.shape = shape
    }
    
    nonisolated public func path(in rect: CGRect) -> Path {
        shape.path(in: rect)
    }
    
    nonisolated public func inset(by amount: CGFloat) -> AnyInsettableShape {
        AnyInsettableShape(shape.inset(by: amount))
    }
    
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
    
}
