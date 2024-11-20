import SwiftUI


struct ContainedBoundsContext: ViewModifier {
    
    let id: AnyHashable
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(ContainedBoundsKey.self){ values in
                GeometryReader { proxy in
                    let matches = values.filter{ $0.context == id }
                    let frame = proxy.frame(in: .local)
                    
                    ForEach(matches.indices, id: \.self){ i in
                        let match = matches[i]
                        let rect = proxy[match.anchor]
                        let state: ContainedBoundsState = {
                            if frame.contains(rect){
                                return .fullyContained
                            } else if frame.intersects(rect) {
                                var edgesOverlap: Edge.Set = []
                                
                                if rect.maxX > frame.maxX { edgesOverlap.insert(.trailing) }
                                if rect.minX < frame.minX { edgesOverlap.insert(.leading) }
                                if rect.maxY > frame.maxY { edgesOverlap.insert(.bottom) }
                                if rect.minY < frame.minY { edgesOverlap.insert(.top) }
                                
                                return .partiallyContained(edges: edgesOverlap)
                            } else {
                                return .notContained
                            }
                        }()
                        
                        Color.clear.onChangePolyfill(of: state, initial: true){
                            match.didChangeVisibility(state)
                        }
                    }
                }
            }
    }
    
}
