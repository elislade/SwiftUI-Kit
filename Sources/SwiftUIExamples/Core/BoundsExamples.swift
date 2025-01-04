import SwiftUIKit


public struct BoundsExamples: View {

    @State private var randomStartLocations: [CGPoint] = []
    @State private var bounds: [CGRect] = []
    @State private var boundIndicesTouching: Set<Int> = []
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ZStack {
                    Color.clear
                    
                    ForEach(randomStartLocations.indices, id: \.self){ i in
                        Child()
                            .offset(
                                x: randomStartLocations[i].x,
                                y: randomStartLocations[i].y
                            )
                    }
                    
                    ForEach(bounds.indices, id: \.self){
                        let b = bounds[$0]
                        
                        Rectangle()
                            .strokeBorder(boundIndicesTouching.contains($0) ? Color.red : .primary, lineWidth: 2)
                            .frame(width: b.width, height: b.height)
                            .position(b.origin)
                            .offset(x: b.width / 2, y: b.height / 2)
                    }
                }
                .onAppear {
                    let x = proxy.size.width / 2
                    let y = proxy.size.height / 2
                    for _ in 0...5 {
                        randomStartLocations.append(.init(
                            x: .random(in: -x...x),
                            y: .random(in: -y...y)
                        ))
                    }
                }
                .childBoundsChange(tag: "Child", in: proxy){
                    bounds = $0
                    boundIndicesTouching = []
                    
                    for i in bounds.indices {
                        for j in bounds.indices {
                            guard j != i else { continue }
                            if bounds[i].intersects(bounds[j]) {
                                boundIndicesTouching.insert(i)
                                boundIndicesTouching.insert(j)
                            }
                        }
                    }
                }
            }
            .background(.bar)
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Tagged Bounds")
                .padding()
        }
        
    }
    
    
    struct Child : View {
        
        @State private var offset = CGPoint()
        @State private var translation: CGSize?
        @State private var color = Color.random
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
            Text(tagged ? "Tagged" : "Not Tagged")
                .font(.exampleParameterTitle)
                .padding()
                .foregroundStyle(.white)
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color)
                }
                .bounds(tag: "Child", active: tagged)
                .offset(x: location.x, y: location.y)
                .animation(translation == nil ? .fastSpringInterpolating : .fastSpringInteractive, value: location)
                .gesture(
                    DragGesture(coordinateSpace: .global).onChanged{ g in
                        translation = g.translation
                    }.onEnded{ g in
                        let pt = g.predictedEndTranslation
                        let t = g.translation
                        let x = powRetainSign(pt.width - t.width, 0.5)
                        let y = powRetainSign(pt.height - t.height, 0.6)
                        translation = nil
                        offset.x += t.width + x
                        offset.y += t.height + y
                    }
                )
        }
        
    }

}


#Preview("Bounds") {
    BoundsExamples()
        .previewSize()
}
