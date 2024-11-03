import SwiftUI

public struct LineShape: Shape {
    
    let axis: Axis
    let anchor: UnitPoint
    var inset: CGFloat = 0
    
    public init(axis: Axis, anchor: UnitPoint = .center) {
        self.axis = axis
        self.anchor = anchor
    }
    
    public func path(in rect: CGRect) -> Path {
        Path{ ctx in
            switch axis {
            case .horizontal:
                ctx.move(to: .init(x: 0, y: rect.height * anchor.y))
                ctx.addLine(to: .init(x: rect.width, y: rect.height * anchor.y))
            case .vertical:
                ctx.move(to: .init(x: rect.width * anchor.x, y: 0))
                ctx.addLine(to: .init(x: rect.width * anchor.x, y: rect.height))
            }
        }
    }
    
}


extension LineShape: InsettableShape {
    
    public func inset(by amount: CGFloat) -> LineShape {
        var copy = self
        copy.inset += amount
        return copy
    }
    
}
