import SwiftUI


public protocol DragSessionStackLayout: RelativeCollectionLayoutModifier {
    
    init(isExpanded: Bool, location: CGPoint)
    
}


public struct DefaultDraggingLayout: DragSessionStackLayout {
    
    let isExpanded: Bool
    let location: CGPoint
    
    private let tailDelay: TimeInterval = 0.4
    
    public init(isExpanded: Bool, location: CGPoint = .zero) {
        self.isExpanded = isExpanded
        self.location = location
    }
    
    public func layoutItem(_ content: Content, index: Int, count: Int) -> some View {
        let c = Double(count)
        let i = Double(index)
        let ri = c - i - 1
        let falloff = powRetainSign(ri, 0.5)
        let tailStep = tailDelay / c

        content
            .isHighlighted()
            .shadow(
                color: .black.opacity(0.3),
                radius: isExpanded ? 10 : 2,
                y: isExpanded ? -5 : 1
            )
            .scaleEffect(isExpanded ? 1 + (falloff * -0.05) : 1)
            .rotationEffect(
                isExpanded ? .degrees(ri * -2) : .degrees(sin(ri) * 5),
                anchor: .init(x: 0.2, y: 0.8)
            )
            .offset(y: isExpanded ? falloff * -50 : 0)
            .animation(.interactiveSpring(duration: (c - i) * tailStep, extraBounce: 0.15), value: location)
            .zIndex(i)
    }
    
}


struct DraggingZStack<Value: Hashable, Layout: RelativeCollectionLayoutModifier>: View {
    
    @Namespace private var ns
    let layout: Layout
    let location: CGPoint
    let items: [DragItem<Value>]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.clear
            
            ForEach(items, id: \.self){ item in
                layout.layoutItem(
                    item.view(),
                    index: items.firstIndex(of: item)!,
                    count: items.count
                )
                .matchedGeometryEffect(id: item, in: ns)
                .id(item)
                .offset(x: location.x - item.origin.x, y: location.y - item.origin.y)
                .position(item.origin)
                //.animation(.bouncy, value: location)
            }
        }
       // .animation(.bouncy, value: location)
    }
    
}


#Preview {
    InlineState(Namespace()) { ns in
        InlineBinding(true) { expanded in
            InlineBinding(CGPoint(x: 150, y: 350)) { loc in
                DraggingZStack(
                    layout: DefaultDraggingLayout(
                        isExpanded: expanded.wrappedValue,
                        location: loc.wrappedValue
                    ),
                    location: loc.wrappedValue,
                    items: (0..<5).map{ i in
                        .stub(i){
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hue: 0.5 + (Double(i) / 10), saturation: 1, brightness: 1))
                                
                                .frame(width: 80, height: 80)
                                .transitions(.scale(1).animation(.smooth))
                        }
                    }
                )
                .animation(.bouncy, value: expanded.wrappedValue)
                .contentShape(.interaction, Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged{
                            loc.wrappedValue = $0.location
                        }
                        .onEnded{ _ in expanded.wrappedValue.toggle() }
                )
            }
        }
    }
}
