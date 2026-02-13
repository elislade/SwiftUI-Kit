import SwiftUIKit


public struct BoundsExamples: View {

    @State private var items: [CGPoint] = []
    @State private var touchingIndices: Set<Int> = []
    
    private func randomItems(in size: CGSize) {
        let x = size.width / 2, y = size.height / 2
        items = (0...10).map { _ in
            .init(
                x: .random(in: -x...x),
                y: .random(in: -y...y)
            )
        }
    }
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            ExampleView(title: "Tagged Bounds"){
                Color.clear.overlay {
                    ForEach(items.indices, id: \.self){ i in
                        let isTouching = touchingIndices.contains(i)
                        Child()
                            .blendMode(isTouching ? .multiply : .normal)
                            .foregroundStyle(
                                isTouching ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary)
                            )
                            .offset(x: items[i].x, y: items[i].y)
                    }
                }
                .drawingGroup()
                .ignoresSafeArea()
                .onAppear { randomItems(in: proxy.size) }
                .childBoundsChange(tag: "Child", in: proxy){ bounds in
                    var newIndices: Set<Int> = []
                    for i in bounds.indices {
                        for j in bounds.indices {
                            guard
                                j != i,
                                !newIndices.contains(i) || !newIndices.contains(j)
                            else { continue }
                            
                            if bounds[i].intersects(bounds[j]) {
                                newIndices.insert(i)
                                newIndices.insert(j)
                            }
                        }
                    }
                    touchingIndices = newIndices
                }
                .allowsHitTesting(false)
            } parameters: {
                Button{
                    withAnimation(.bouncy){
                        randomItems(in: proxy.size)
                    }
                } label: {
                    Label("Randomize", systemImage: "dice")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    
    struct Child : View {
        
        @State private var size = CGSize(.random(in: 50...150))
        @State private var offset = CGPoint()
        @State private var translation: CGSize?
        @State private var tagged = Bool.random()
        
        private var location: CGPoint {
            if let translation {
                return CGPoint(
                    x: offset.x + translation.width,
                    y: offset.y + translation.height
                )
            } else {
                return offset
            }
        }
        
        var body: some View {
            Circle()
                .frame(width: size.width, height: size.width)
                .bounds(tag: "Child")
                .border(Color.secondary.opacity(0.3), width: 1)
                .offset(x: location.x, y: location.y)
                .animation(translation == nil ? .fastSpringInterpolating : .fastSpringInteractive, value: location)
                #if !os(tvOS)
                .gesture(
                    DragGesture(
                        minimumDistance: 0,
                        coordinateSpace: .global
                    )
                    .onChanged{ translation = $0.translation }
                    .onEnded{ g in
                        let pt = g.predictedEndTranslation
                        let t = g.translation
                        let x = powRetainSign(pt.width - t.width, 0.5)
                        let y = powRetainSign(pt.height - t.height, 0.8)
                        translation = nil
                        offset.x += t.width + x
                        offset.y += t.height + y
                    }
                )
                #endif
        }
        
    }

}


#Preview("Bounds") {
    BoundsExamples()
        .previewSize()
}
