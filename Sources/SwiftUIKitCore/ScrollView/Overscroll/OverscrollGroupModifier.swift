import SwiftUI


struct OverscrollGroupModifier {
    
    @Environment(\.scrollOffsetPassthrough) private var scrollOffset
    
    @State private var inRange: Bool = false
    @State private var itemIndex: Int?
    @State private var hasMatchedCompletion = false
    
    var scrollRange: ClosedRange<CGFloat> = 10...110
    
    private func reset() {
        itemIndex = nil
        inRange = false
    }
    
    func body(content: Content) -> some View {
        content.backgroundPreferenceValue(OverscrollElementPreference.self){ items in
            if let scrollOffset, !items.isEmpty, inRange {
                GeometryReader { proxy in
                    Color.clear.onReceive(scrollOffset.map(\.y).filter{ _ in !hasMatchedCompletion }){ y in
                        if let itemIndex, items.indices.contains(itemIndex) {
                            let progress = y.fraction(in: scrollRange)
                            items[itemIndex].action(progress)
                            for i in items.indices {
                                guard i != itemIndex else { continue }
                                items[i].action(0)
                            }
                            
                            if progress >= 1 {
                               hasMatchedCompletion = true
                           }
                        } else {
                            for i in items.indices {
                                guard i != itemIndex else { continue }
                                items[i].action(0)
                            }
                            reset()
                        }
                    }
                    .onWindowDrag{ evt in
                        if evt.phase == .changed {
                            guard let location = evt.locations.first else {
                                return
                            }
                            
                            let point = CGPoint(x: location.x, y: proxy.size.height)
                            let rects = items.map{ proxy[$0.anchor] }
                            let closestIndices = rects.indices.sorted(by: {
                                point.distance(from: rects[$0]) < point.distance(from: rects[$1])
                            })
                            
                            itemIndex = closestIndices.first
                        } else if evt.phase == .ended {
                            reset()
                            for item in items {
                                item.action(0)
                            }
                        }
                    }
                    .onDisappear{
                        reset()
                    }
                }
            }
        }
        .background{
            if let scrollOffset {
                Color.clear.onReceive(scrollOffset.map{ scrollRange.contains($0.y) }){
                    inRange = $0
                }
            }
        }
        .onWindowDrag{ evt in
            if evt.phase == .ended {
                reset()
                hasMatchedCompletion = false
            }
        }
    }
    
}

extension OverscrollGroupModifier: ViewModifier {}
