import SwiftUI


public struct AnyInsettableShape: InsettableShape {
    
    let shape: any InsettableShape
    
    public init<S: InsettableShape>(_ shape: S) {
        self.shape = shape
    }
    
    public func path(in rect: CGRect) -> Path {
        shape.path(in: rect)
    }
    
    public func inset(by amount: CGFloat) -> AnyInsettableShape {
        AnyInsettableShape(shape.inset(by: amount))
    }
    
    public nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
    
}
