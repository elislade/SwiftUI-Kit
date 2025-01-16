import SwiftUI


public struct DropStack<Value: Hashable, Content: View, Cursor: View>: View {
    
    @Namespace private var namespace
    
    @State private var drop: DropGroup<Value>?
    @State private var isTargeting: Bool = false
    @State private var pendingIndex: Int?
    @State private var draggingIndices: IndexSet = []
    
    private let axis: Axis
    private let alignment: Alignment
    private let spacing: CGFloat?
    @Binding private var data: [Value]
    private let location: CGPoint?
    private let removeOnCancel: Bool
    private let overrideShouldTarget: ((CGPoint, CGRect) -> Bool)?
    private let isTargeted: (Bool) -> Void
    private let content: (Value) -> Content
    private let cursor: () -> Cursor
    
    public init(
        axis: Axis,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        data: Binding<[Value]>,
        location: CGPoint? = nil,
        removeOnCancel: Bool = false,
        overrideShouldTarget: ((CGPoint, CGRect) -> Bool)? = nil,
        isTargeted: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder cursor: @escaping () -> Cursor
    ) {
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self._data = data
        self.location = location
        self.content = content
        self.cursor = cursor
        self.removeOnCancel = removeOnCancel
        self.isTargeted = isTargeted
        self.overrideShouldTarget = overrideShouldTarget
    }
    
    private var reorderingData: [Value] {
        draggingIndices.isEmpty ? data : data.indices.compactMap { i in
            draggingIndices.contains(i) ? nil : data[i]
        }
    }
    
    public var body: some View {
        ZStack(alignment: alignment) {
            Color.clear
            AxisStack(axis, alignment: alignment, spacing: spacing) {
                ForEach(reorderingData, id: \.self){ item in
                    let idx = reorderingData.firstIndex(of: item)!
                    if pendingIndex == idx {
                        cursor()
                            .transitions(.scale(1))
                            .matchedGeometryEffect(id: "Cursor", in: namespace)
                            .zIndex(1)
                    }
                    
                    content(item)
                        .reorderingItem()
                        .zIndex(2)
                        .dragItem(item){ isDragging in
                            if isDragging {
                                let idx = data.firstIndex(of: item)!
                                draggingIndices.insert(idx)
                            }
                        }
                }
                
                if let pendingIndex, !reorderingData.indices.contains(pendingIndex) {
                    cursor()
                        .transitions(.scale(1))
                        .matchedGeometryEffect(id: "Cursor", in: namespace)
                        .zIndex(1)
                }
            }
        }
        .animation(.bouncy, value: pendingIndex)
        .animation(.bouncy, value: draggingIndices)
        .onChangePolyfill(of: isTargeting){
            isTargeted(isTargeting)
        }
        .reorderingContext(
            axis: axis,
            location: isTargeting ? drop?.locationInWindow : nil,
            didChangeIndex: { pendingIndex = $0 },
            overrideHitTest: overrideShouldTarget
        )
        .dropArea(Value.self, shouldTarget: overrideShouldTarget){
            isTargeting = $0
        } didChange: {
            drop = $0
        } didComplete: { didCompleteInThisArea in
            guard let group = drop else { return }
            
            if let pendingIndex {
                data.remove(atOffsets: draggingIndices)

                if data.indices.contains(pendingIndex){
                    data.insert(contentsOf: group.items, at: pendingIndex)
                    
                } else {
                    data.append(contentsOf: group.items)
                }
            } else {
                data.append(contentsOf: group.items)
            }
            
            drop = nil
            pendingIndex = nil
            draggingIndices = []
        } didCancel: {
            if removeOnCancel, let drop {
                for item in drop.items {
                    data.removeAll(where: { $0 == item })
                }
            }
            drop = nil
            pendingIndex = nil
            draggingIndices = []
        }
    }
    
}
