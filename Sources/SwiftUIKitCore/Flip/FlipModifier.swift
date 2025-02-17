import SwiftUI


struct FlipModifier<FlipView: View>: ViewModifier {
    
    let isFlipped: Bool
    let horizontalEdge: HorizontalEdge?
    let verticalEdge: VerticalEdge?
    private let flippedContent: () -> FlipView
    
    init(
        isFlipped: Bool,
        horizontalEdge: HorizontalEdge? = nil,
        verticalEdge: VerticalEdge? = nil,
        content: @escaping () -> FlipView
    ) {
        self.isFlipped = isFlipped
        self.flippedContent = content
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
                .conditonallyShow(animatingCondition: !isFlipped)
                .zIndex(1)
            
            flippedContent()
                .rotation3DEffect(.degrees(180), axis: axis)
                .conditonallyShow(animatingCondition: isFlipped)
                .zIndex(2)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: axis,
            perspective: 0.8
        )
    }
    
}
