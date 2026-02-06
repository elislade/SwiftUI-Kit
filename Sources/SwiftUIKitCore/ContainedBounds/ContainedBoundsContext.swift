import SwiftUI


struct ContainedBoundsContext {
    
    @Environment(\.layoutDirection) private var layoutDirection
    let id: AnyHashable
    
}


extension ContainedBoundsContext: ViewModifier {
    
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
                                return .init(edges: [], containment: .fully)
                            } else {
                                var edges: Edge.Set = []
                                
                                if rect.maxX > frame.maxX { edges.insert(layoutDirection == .rightToLeft ? .leading : .trailing) }
                                if rect.minX < frame.minX { edges.insert(layoutDirection == .rightToLeft ? .trailing : .leading) }
                                
                                if rect.maxY > frame.maxY { edges.insert(.bottom) }
                                if rect.minY < frame.minY { edges.insert(.top) }
                                
                                return .init(
                                    edges: edges,
                                    containment: frame.intersects(rect) ? .partially : .none
                                )
                            }
                        }()
                        
                        Color.clear.onChangePolyfill(of: state, initial: true){
                            match.didChangeVisibility(state)
                        }
                    }
                }
            }
            .transformPreference(ContainedBoundsKey.self){ value in
                value = value.filter({ id != $0.context })
            }
    }
    
    
}
