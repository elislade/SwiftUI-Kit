import SwiftUI


public struct PointedCircle : Shape {
    
    private var rotation: Double
    private var inset: Double = 0
    
    public init(edge: Edge) {
        self.rotation = switch edge {
        case .top: 180
        case .leading: 90
        case .bottom: 0
        case .trailing: 270
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        return UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: radius,
            topTrailingRadius: radius
        )
        .rotation(.degrees(rotation - 45))
        .inset(by: inset)
        .path(in: rect)
    }
    
    public nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let smallest = min(size.width, size.height)
        return CGSize(width: smallest, height: smallest)
    }
    
}


extension PointedCircle : InsettableShape {
    
    public nonisolated func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.inset += amount
        return copy
    }
    
}


extension PointedCircle {
    
    public typealias AnimatableData = AnimatableTwin<Double>
    
    nonisolated public var animatableData: AnimatableTwin<Double> {
        get { .init(rotation, inset) }
        set {
            rotation = newValue.first
            inset = newValue.second
        }
    }
    
}
