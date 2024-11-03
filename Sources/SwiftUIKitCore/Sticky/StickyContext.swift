import SwiftUI

struct StickyContext : ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    let grouping: StickyGrouping
    
    private func calculateSticky(in proxy: GeometryProxy, for items: [StickyPreferenceValue]) {
        var resolvedItems = items
        
        for i in resolvedItems.indices {
            resolvedItems[i].resolvedFrame = proxy[resolvedItems[i].anchor]
        }
        
        var updates : [PendingUpdate] = []
        
        defer {
            for item in resolvedItems {
                if let update = updates.first(where: { item.id == $0.item.id }) {
                    update.finalize()
                } else {
                    item.update(.init(), .init())
                }
            }
        }
        
        for edge in Edge.allCases {
            let items = resolvedItems.sorted(startingFrom: edge)
            var stackedSize = CGFloat()
            
            for i in items.indices {
                let item = items[i]
                guard let itemInset = item.insets[edge] else { continue }
                
                let itemFrame = item.resolvedFrame
                let itemGrouping = item.grouping ?? grouping
                
                var offset = CGFloat()
                var appliedGrouping: StickyGrouping = .none
                
                let normalizedFactor: CGFloat = edge == .bottom || edge == .trailing ? -1 : 1
                let dimension = itemFrame.normalizedDimension(for: edge, in: proxy.size)
                let itemSize = itemFrame.size.dimension(for: Axis(orthogonalTo: edge))
                
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
                
                if itemGrouping == .displaced && i != items.indices.last {
                    for j in items.indices {
                        guard j > i else { continue }
                        
                        let candidate = items[j]
                        let candidateFrame = candidate.resolvedFrame
                        
                        guard candidate.categoryMask.intersects(with: item.categoryMask) || candidate.categoryMask == item.categoryMask else { continue }
                        guard let candidateInset = candidate.insets[edge] else { continue }
                        
                        let candidateDimension = candidateFrame.normalizedDimension(for: edge, in: proxy.size)
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
                
                if let updateIdx = updates.firstIndex(where: { $0.item.id == item.id }) {
                    updates[updateIdx].edges[edge] = offset
                    updates[updateIdx].grouping[edge] = appliedGrouping
                } else {
                    updates.append(.init(
                        item: item,
                        grouping: [edge : appliedGrouping],
                        edges: [edge: offset]
                    ))
                }
            }
            
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(StickyPreferenceKey.self) { value in
                GeometryReader{ proxy in
                    Color.clear
                        .onAppear{ calculateSticky(
                            in: proxy,
                            for: value
                        ) }
                        .onChange(of: value){
                            calculateSticky(in: proxy, for: $0)
                        }
                }
                .hidden()
            }
    }
    
    
    struct PendingUpdate {
        
        let item: StickyPreferenceValue
        var grouping: [Edge: StickyGrouping] = [:]
        var edges: [Edge: CGFloat] = [:]
        
        func finalize() {
            let stickingEdges = edges.keys.reduce(into: Edge.Set()){ result, edge in
                result.formUnion(.init(edge))
            }
            
            let offset = CGPoint(
                x: edges[.leading] ?? edges[.trailing] ?? 0,
                y: edges[.top] ?? edges[.bottom] ?? 0
            )
            
            let hg = grouping[.leading] == StickyGrouping.none ? grouping[.trailing] : grouping[.leading]
            let vg = grouping[.top] ==  StickyGrouping.none ? grouping[.bottom] : grouping[.top]
            
            //print(hg, vg)
            
            let state = StickingState(
                stickingEdges: stickingEdges,
                horizontalGrouping: hg ?? .none,
                verticalGrouping: vg ?? .none
            )
            
            item.update(offset, state)
        }
        
    }
    
    
}


struct StickyPreferenceKey: PreferenceKey {
    
    static var defaultValue: [StickyPreferenceValue] = []
    
    static func reduce(value: inout [StickyPreferenceValue], nextValue: () -> [StickyPreferenceValue]) {
        value.append(contentsOf: nextValue())
    }
    
}


extension Collection where Element == StickyPreferenceValue {
    
    func sorted(startingFrom edge: Edge) -> [Element] {
        sorted(by: {
            switch edge {
            case .top: $0.resolvedFrame.origin.y < $1.resolvedFrame.origin.y
            case .leading: $0.resolvedFrame.origin.x < $1.resolvedFrame.origin.x
            case .bottom: $0.resolvedFrame.origin.y > $1.resolvedFrame.origin.y
            case .trailing: $0.resolvedFrame.origin.x > $1.resolvedFrame.origin.x
            }
        })
    }
    
}


extension CGRect {
    
    func isAfter(other rect: CGRect, startingFrom edge: Edge) -> Bool {
        switch edge {
        case .top: minY > rect.minY
        case .leading: minX > rect.minX
        case .bottom: maxY < rect.maxY
        case .trailing: maxX < rect.maxX
        }
    }

//    func overlaps(with other: CGRect, parallelTo axis: Axis) -> Bool {
//        switch axis {
//        case .horizontal: maxX < other.minX || minX > other.maxX
//        case .vertical: maxY < other.minY //|| minY < other.maxY
//        }
//    }
//    
//    func overlaps(with other: CGRect, perpendicularTo axis: Axis) -> Bool {
//        switch axis {
//        case .horizontal: maxY < other.minY || minY > other.maxY || minY == other.minY
//        case .vertical: maxX < other.minX || minX > other.maxX || minX == other.minX
//        }
//    }
  
}

