import SwiftUI

struct StickyContext : ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    let grouping: StickyGrouping
    
    private func calculateSticky(in proxy: GeometryProxy, for items: [StickyPreferenceValue]) {
        var items = items.map{
            PendingUpdate(item: $0, frame: proxy[$0.anchor])
        }
        
        defer {
            items.forEach { $0.finalize() }
        }
        
        for edge in Edge.allCases {
            let edgeItems = items.sorted(startingFrom: edge)
            var stackedSize = CGFloat()
            
            for i in edgeItems.indices {
                let item = edgeItems[i]
                guard let itemInset = item.insets[edge] else { continue }
                
                let itemGrouping = item.grouping ?? grouping
                
                var offset = CGFloat()
                var appliedGrouping: StickyGrouping = .none
                
                let normalizedFactor: CGFloat = edge == .bottom || edge == .trailing ? -1 : 1
                let dimension = item.frame.normalizedDimension(for: edge, in: proxy.size)
                let itemSize = item.frame.size[Axis(orthogonalTo: edge)]
                
                if itemGrouping == .displaced {
                    if itemInset > dimension {
                        offset -= dimension * normalizedFactor
                        offset += itemInset * normalizedFactor
                    } else { continue }
                } else if itemGrouping == .stacked {
                    if itemInset > dimension - stackedSize {
                        offset -= (dimension - stackedSize) * normalizedFactor
                        offset += itemInset * normalizedFactor
                        stackedSize += (itemSize + itemInset)
                        appliedGrouping = .stacked
                    } else { continue }
                } else {
                    if itemInset > dimension {
                        offset -= dimension * normalizedFactor
                        offset += itemInset * normalizedFactor
                    } else { continue }
                }
                
                if itemGrouping == .displaced && i != edgeItems.indices.last {
                    for j in edgeItems.indices {
                        guard j > i else { continue }
                        
                        let candidate = edgeItems[j]
                        
                        guard candidate.categoryMask.intersects(with: item.categoryMask) || candidate.categoryMask == item.categoryMask else { continue }
                        guard let candidateInset = candidate.insets[edge] else { continue }
                        
                        let candidateDimension = candidate.frame.normalizedDimension(for: edge, in: proxy.size)
                        let candidateDisplacement = candidateDimension - itemSize
                        if ((candidateDisplacement - candidateInset) - itemInset) < 0 {
                            if edge == .bottom || edge == .trailing {
                                offset = (offset - candidateDisplacement) + candidateInset + itemInset
                            } else {
                                offset = (offset + candidateDisplacement) - candidateInset - itemInset
                            }
                            appliedGrouping = .displaced
                        }
                    }
                }
                
                let updateIdx = items.firstIndex(where: { $0.id == item.id })!
                items[updateIdx].pendingEdges[edge] = offset
                items[updateIdx].pendingGrouping[edge] = appliedGrouping
            }
            
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(StickyPreferenceKey.self) { value in
                GeometryReader{ proxy in
                    Color.clear
                        .onChangePolyfill(of: value, initial: true){
                            calculateSticky(in: proxy, for: value)
                        }
                }
                .hidden()
            }
    }
    
    
    @dynamicMemberLookup struct PendingUpdate {
        
        let item: StickyPreferenceValue
        let frame: CGRect
        
        var pendingGrouping: [Edge: StickyGrouping] = [:]
        var pendingEdges: [Edge: CGFloat] = [:]
        
        func finalize() {
            let stickingEdges = pendingEdges.keys.reduce(into: Edge.Set()){ result, edge in
                result.formUnion(.init(edge))
            }
            
            let offset = CGPoint(
                x: pendingEdges[.leading] ?? pendingEdges[.trailing] ?? 0,
                y: pendingEdges[.top] ?? pendingEdges[.bottom] ?? 0
            )
            
            let hg = pendingGrouping[.leading] == StickyGrouping.none ? pendingGrouping[.trailing] : pendingGrouping[.leading]
            let vg = pendingGrouping[.top] ==  StickyGrouping.none ? pendingGrouping[.bottom] : pendingGrouping[.top]

            let state = StickingState(
                stickingEdges: stickingEdges,
                horizontalGrouping: hg ?? .none,
                verticalGrouping: vg ?? .none
            )
            
            item.update(offset, state)
        }
        
        subscript<V>(dynamicMember path: KeyPath<StickyPreferenceValue, V>) -> V {
            item[keyPath: path]
        }
        
    }
    
}


struct StickyPreferenceKey: PreferenceKey {
    
    static var defaultValue: [StickyPreferenceValue] { [] }
    
    static func reduce(value: inout [StickyPreferenceValue], nextValue: () -> [StickyPreferenceValue]) {
        value.append(contentsOf: nextValue())
    }
    
}


extension Collection where Element == StickyContext.PendingUpdate {
    
    func sorted(startingFrom edge: Edge) -> [Element] {
        sorted(by: {
            switch edge {
            case .top: $0.frame.origin.y < $1.frame.origin.y
            case .leading: $0.frame.origin.x < $1.frame.origin.x
            case .bottom: $0.frame.origin.y > $1.frame.origin.y
            case .trailing: $0.frame.origin.x > $1.frame.origin.x
            }
        })
    }
    
}
