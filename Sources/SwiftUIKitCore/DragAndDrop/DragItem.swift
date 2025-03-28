import SwiftUI

public struct DragItem<Value: Hashable>: Hashable {
    
    public static func == (lhs: DragItem<Value>, rhs: DragItem<Value>) -> Bool {
        lhs.id == rhs.id && lhs.origin == rhs.origin && lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let origin: CGPoint
    let value: Value
    let view: @MainActor () -> AnyView
    let dispose: @MainActor () -> Void
}

extension DragItem: Sendable where Value: Sendable { }


public extension DragItem {
    
    static func stub<Content: View>(_ value: Value, @ViewBuilder content: @escaping @MainActor () -> Content) -> Self {
        .init(
            id: "\(value)",
            origin: .zero,
            value: value,
            view: { AnyView(content()) },
            dispose: {}
        )
    }
    
}

struct DragItemPreference<Value: Hashable>: PreferenceKey {
    
    static var defaultValue: [DragItem<Value>] { [] }
    
    static func reduce(value: inout [DragItem<Value>], nextValue: () -> [DragItem<Value>]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct DragItemModifier<Value: Hashable, DragView: View>: ViewModifier {
    
    @State private var id: UUID = UUID()
    @Environment(\.dragItemAction) private var dragItemAction
    @Environment(\.dragSessionNamspace) private var dragSessionNamspace
    @Namespace private var ns
    @State private var frame = CGRect()
    @State private var active: Bool = false
    
    let value: Value
    var didChangeDragging: (Bool) -> Void = { _ in }
    let view: () -> DragView
    
    private var name: Namespace.ID {
        dragSessionNamspace ?? ns
    }
    
    private var dragItem: DragItem<Value> {
        DragItem(
            id: id.uuidString,
            origin: frame.origin,
            value: value,
            view: { AnyView(view()) },
            dispose: {
                withAnimation(.bouncy){
                    active = false
                }
            }
        )
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if active {
                Color.clear
                    .frame(width: frame.width, height: frame.height)
            } else {
                content
            }
        }
        .onGeometryChangePolyfill(of: { $0.frame(in: .global).rounded(.toNearestOrEven) }){
            self.frame = $0
        }
        .onChangePolyfill(of: active){
            didChangeDragging(active)
        }
        #if !os(tvOS)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.15, maximumDistance: 200)
                .onEnded{ g in
                    active = true
                    dragItemAction?(dragItem)
                }
        )
        #endif
    }
    
}
