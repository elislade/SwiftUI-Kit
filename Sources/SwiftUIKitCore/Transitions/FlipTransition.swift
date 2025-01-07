import SwiftUI


public extension AnyTransition {
    
    static func flip(horizontal h: HorizontalEdge, vertical v: VerticalEdge) -> AnyTransition {
        .modifier(
            active: FlipTransitionModifier(progress: 1, shouldCompensateRotation: true,  horizontalEdge: h, verticalEdge: v),
            identity: FlipTransitionModifier(progress: 0, horizontalEdge: h, verticalEdge: v)
        )
    }
    
    static func flipHorizontal(_ edge: HorizontalEdge) -> AnyTransition {
        .modifier(
            active: FlipTransitionModifier(progress: 1, horizontalEdge: edge),
            identity: FlipTransitionModifier(progress: 0, horizontalEdge: edge)
        )
    }
    
    static func flipVertical(_ edge: VerticalEdge) -> AnyTransition {
        .modifier(
            active: FlipTransitionModifier(progress: 1, verticalEdge: edge),
            identity: FlipTransitionModifier(progress: 0, verticalEdge: edge)
        )
    }
    
}


struct FlipTransitionModifier: ViewModifier & Animatable & Hashable {
    
    nonisolated var progress: Double
    
    var isShown: Bool = true
    let horizontalEdge: HorizontalEdge?
    let verticalEdge: VerticalEdge?
    let shouldCompensateRotation: Bool
    
    public typealias AnimatableData = Double
    
    public nonisolated var animatableData: AnimatableData {
        get { progress }
        set {
            isShown = newValue < 0.5
            progress = newValue
        }
    }
    
    nonisolated init(
        progress: Double = 0,
        shouldCompensateRotation: Bool = false,
        horizontalEdge: HorizontalEdge? = nil,
        verticalEdge: VerticalEdge? = nil
    ) {
        self.shouldCompensateRotation = shouldCompensateRotation
        self.progress = progress
        self.isShown = progress < 0.5
        self.horizontalEdge = horizontalEdge
        self.verticalEdge = verticalEdge
    }
    
    private var axis: (CGFloat, CGFloat, CGFloat) {
        var y: CGFloat = 0
        var x: CGFloat = 0
        
        if let horizontalEdge {
            if horizontalEdge  == .trailing {
                y = 1
            } else if horizontalEdge  == .leading {
                y = -1
            }
        }
       
        if let verticalEdge {
            if verticalEdge == .top {
                x = 1
            } else if verticalEdge == .bottom {
                x = -1
            }
        }
        
        return (x,y,0)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .rotation3DEffect(.degrees(shouldCompensateRotation ? (180) : 0), axis: axis)
                .opacity(isShown ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(progress * 180),
            axis: axis,
            perspective: 0.5
        )
    }
    
}

