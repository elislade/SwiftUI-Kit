import SwiftUI


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LineWrapLayout: Layout {
    
    public var alignment: TextAlignment
    public var lineSpacing: Double
    
    private var alignmentFactor: Double {
        switch alignment {
        case .leading: 0
        case .center: 0.5
        case .trailing: 1
        }
    }
    
    public init(alignment: TextAlignment = .leading, lineSpacing: Double = 0) {
        self.alignment = alignment
        self.lineSpacing = lineSpacing
    }
    
    public func makeCache(subviews: Subviews) -> [LayoutLine] {
        []
    }
    
    private func makeLines(subviews: Subviews, in size: CGSize) -> [LayoutLine] {

        // Make Groups
        let groups = subviews.indices.reduce(into: GroupReducerState()){ state, idx in
            let view = subviews[idx]
            let isSparator = view[SeparatorKey.self]
            let numberOfNewlines = view[NewlineKey.self]
            
            if numberOfNewlines == 0 {
                state.groups.append(LayoutGroup([
                    .init(index: idx, size: view.sizeThatFits(.unspecified))
                ]))
            } else {
                for _ in 0..<numberOfNewlines {
                    state.groups.append(LayoutGroup())
                }
                
                state.separatorLast = state.groups.count
            }
            
            if isSparator || (idx == subviews.indices.last && state.hasSeparated) {
                let range = state.separatorLast..<state.groups.endIndex
                let groups = state.groups[range].splitMerge(where: { $0.items.isEmpty })
                state.groups.remove(atOffsets: IndexSet(range))
                state.groups.append(contentsOf: groups)
                state.separatorLast = state.groups.count
                state.hasSeparated = true
            }
        }.groups
        
        
        // Layout Groups
        
        var x: Double = 0, y: Double = 0
        var lines: [LayoutLine] = []
        
        for idx in groups.indices {
            let groupSize = groups[idx].computedSize
            
            if lines.isEmpty {
                groups[idx].origin.x = x
                lines.append(LayoutLine([groups[idx]]))
                x += groupSize.width
            } else if x + groupSize.width > size.width || groups[idx].items.isEmpty  {
                x = 0
                groups[idx].origin.x = x
                lines.append(LayoutLine([groups[idx]]))
                x += groupSize.width
            } else {
                if groups[idx - 1].items.isEmpty {
                    lines.append(LayoutLine([groups[idx]]))
                } else {
                    groups[idx].origin.x = x
                    lines[lines.endIndex - 1].groups.append(groups[idx])
                }
                
                x += groupSize.width
            }
        }
        
        // Layout Lines
        
        for i in lines.indices {
            let lineSize = lines[i].maxHeight
            lines[i].offset = CGPoint(x: 0, y: y)
            y += (lineSize + lineSpacing)
        }
        
        return lines
    }
    
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout [LayoutLine]) -> CGSize {
        let size = CGSize(width: proposal.width ?? 0, height: 10000)
        cache = makeLines(subviews: subviews, in: size)
        
        return cache.indices.reduce(into: CGRect()){ res, idx in
            cache[idx].cacheComputedRect()
            res = res.union(cache[idx].cachedRect)
        }.size
    }
    
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout [LayoutLine]) {
        
        //TODO: Impliment RTL support.
        //let layoutDirection = subviews.layoutDirection
        
        for line in cache {
            let lineSize = line.cachedRect.size
            let xOffset = (bounds.width - lineSize.width) * alignmentFactor
            for group in line.groups {
                var x: Double = group.origin.x + line.offset.x + bounds.minX + xOffset
                
                for item in group.items {
                    let location = CGPoint(x: x, y: line.offset.y + bounds.minY)
                    subviews[item.index].place(at: location, proposal: .unspecified)
                    x += item.size.width
                }
            }
        }
    }
    
}




@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension LineWrapLayout {
    
    struct GroupReducerState {
        var groups: [LayoutGroup] = []
        var hasSeparated: Bool = false
        var separatorLast: Int = 0
    }
    
    final class LayoutGroup: @unchecked Sendable, Equatable, Codable {
        
        static func == (lhs: LayoutGroup, rhs: LayoutGroup) -> Bool {
            lhs.origin == rhs.origin && lhs.items == rhs.items
        }
        
        var origin: CGPoint
        var items: [Item] = []
        
        init(_ items: [Item] = []){
            self.origin = .zero
            self.items = items
        }
        
        final class Item: @unchecked Sendable, Equatable, Codable {
            static func == (lhs: LineWrapLayout.LayoutGroup.Item, rhs: LineWrapLayout.LayoutGroup.Item) -> Bool {
                lhs.size == rhs.size && lhs.index == rhs.index
            }
            
            let index: Int
            let size: CGSize
            
            init(index: Int, size: CGSize) {
                self.index = index
                self.size = size
            }
        }
        
        var computedSize: CGSize {
            items.reduce(into: CGSize()) { total, item in
                total.width += item.size.width
                if total.height < item.size.height {
                    total.height = item.size.height
                }
            }.round(to: 1)
        }
        
        var computedRect: CGRect {
            CGRect(origin: origin, size: computedSize)
        }
        
    }
    
    
    public final class LayoutLine: @unchecked Sendable, Equatable, Codable {
        
        public static func == (lhs: LayoutLine, rhs: LayoutLine) -> Bool {
            lhs.offset == rhs.offset && lhs.groups == rhs.groups
        }
        
        var offset: CGPoint
        var groups: [LayoutGroup]
        
        init(_ groups: [LayoutGroup] = []){
            self.offset = .zero
            self.groups = groups
        }
        
        private(set) var cachedRect: CGRect = .zero
        
        var maxHeight: CGFloat {
            groups.flatMap(\.items).reduce(into: 0.0){ res, partial in
                if partial.size.height > res {
                    res = partial.size.height
                }
            }
        }
        
        var computedSize: CGSize {
            groups.reduce(into: CGRect()){ $0 = $0.union($1.computedRect) }.size
        }
        
        var computedRect:  CGRect {
            CGRect(origin: offset, size: computedSize)
        }
        
        var isEmpty: Bool {
            groups.allSatisfy(\.items.isEmpty)
        }
        
        func cacheComputedRect() {
            cachedRect = computedRect
        }
        
    }
    
    
    struct NewlineKey: LayoutValueKey {
        static var defaultValue: Int { 0 }
    }

    struct KerningKey: LayoutValueKey {
        static var defaultValue: Double { 0 }
    }

    struct SeparatorKey: LayoutValueKey {
        static var defaultValue: Bool { false }
    }
    
}


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LayoutSeparator: View {
    
    public init(){}
    
    public var body: some View {
        Color.clear.layoutSaparator()
    }
}


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct LayoutNewLine: View {
    
    let lines: Int
    
    public init(_ lines: Int = 1) {
        self.lines = max(lines, 0)
    }
    
    public var body: some View {
        Color.clear.layoutNewlines(lines)
    }
    
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    func layoutNewline(_ enabled: Bool = true) -> some View {
        layoutValue(key: LineWrapLayout.NewlineKey.self, value: enabled ? 1 : 0)
    }
    
    func layoutNewlines(_ lines: Int = 1) -> some View {
        layoutValue(key: LineWrapLayout.NewlineKey.self, value: max(lines, 0))
    }
    
    func layoutSaparator(_ enabled: Bool = true) -> some View {
        layoutValue(key: LineWrapLayout.SeparatorKey.self, value: enabled)
    }
    
    func layoutKerning(_ kerning: Double = 0) -> some View {
        layoutValue(key: LineWrapLayout.KerningKey.self, value: kerning)
    }
    
    func layoutTracking(_ tracking: CGFloat) -> some View {
        padding(.horizontal, tracking)
    }
    
    func layoutLeading(_ leading: CGFloat) -> some View {
        padding(.bottom, leading)
    }
    
}


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Collection where Element == LineWrapLayout.LayoutGroup {
    
    func splitMerge(where shouldSplit: @escaping (Element) -> Bool) -> [Element] {
        guard isEmpty == false else { return [] }
        return reduce(into: [Element]()){ res, partial in
            if shouldSplit(partial) || res.isEmpty {
                res.append(partial)
            } else {
                if shouldSplit(res[res.count - 1]) {
                    res.append(partial)
                } else {
                    res[res.count - 1].items.append(contentsOf: partial.items)
                }
            }
        }
    }
    
    
}
