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
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
    
}
