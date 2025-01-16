import SwiftUI


public extension View {
    
    func reorderingContext(
        axis: Axis = .horizontal,
        location: CGPoint?,
        didChangeIndex: @escaping (Int?) -> Void,
        overrideHitTest: ((CGPoint, CGRect) -> Bool)? = nil
    ) -> some View {
        modifier(ReorderingContext(
            axis: axis,
            locationInWindow: location,
            overrideHitTest: overrideHitTest,
            didChangeIndex: didChangeIndex
        ))
    }
    
    func reorderingItem(included: Bool = true) -> some View {
        modifier(ReorderingItemModifier(included: included))
    }
    
}


struct ReorderingContext: ViewModifier {
  
    let axis: Axis
    var locationInWindow: CGPoint?
    var overrideHitTest: ((CGPoint, CGRect) -> Bool)?
    var didChangeIndex: (Int?) -> Void = { _ in }
    
    @State private var frame: CGRect = .zero
    @State private var items: [ReorderingItem] = []
    
    private func comp(_ frame: CGRect) -> Double {
        switch(axis){
        case .horizontal: return frame.midX
        case .vertical: return frame.midY
        }
    }
    
    private func comp(_ point: CGPoint) -> Double {
        switch(axis){
        case .horizontal: return point.x
        case .vertical: return point.y
        }
    }
    
    private func calculate(for items: [ReorderingItem], loc: CGPoint) -> Int? {
        if let overrideHitTest {
            guard overrideHitTest(loc, frame) else { return nil }
        } else {
            guard frame.contains(loc) else { return nil }
        }

        if items.isEmpty { return 0 }
        
        if let pendingIndex = items.firstIndex(where: { comp($0.frameInWindow) > comp(loc) }){
            return pendingIndex
        } else if comp(items.last?.frameInWindow ?? .zero) < comp(loc) {
            return items.count
        }

        return nil
    }
    
    func body(content: Content) -> some View {
        content
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ frame = $0 }
            .onPreferenceChange(ReorderingPreference.self){
                _items.wrappedValue = $0
            }
            .onChangePolyfill(of: locationInWindow){ old, new in
                if let new {
                    didChangeIndex(calculate(for: items, loc: new))
                } else {
                    didChangeIndex(nil)
                }
            }
    }
    
}


struct ReorderingItem: Hashable, Sendable {
    let id: UUID
    let frameInWindow: CGRect
}

struct ReorderingPreference: PreferenceKey {
    
    static var defaultValue: [ReorderingItem] { [] }
    
    static func reduce(value: inout [ReorderingItem], nextValue: () -> [ReorderingItem]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct ReorderingItemModifier: ViewModifier {
    
    @State private var id: UUID = UUID()
    @State private var frame = CGRect()
    
    var included: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ frame = $0 }
            .preference(
                key: ReorderingPreference.self,
                value: frame != .zero && included ? [
                    .init(
                        id: id,
                        frameInWindow: frame
                    )
                ] : []
            )
    }
    
}
