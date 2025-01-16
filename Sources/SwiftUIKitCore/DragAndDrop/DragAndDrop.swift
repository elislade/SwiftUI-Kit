import SwiftUI


public extension View {
    
    func dragSession<Value: Hashable & Sendable>(_ type: Value.Type) -> some View {
        modifier(DragAndDropSession<Value, DefaultDraggingLayout>())
    }
    
    func dragSession<Value: Hashable & Sendable, Layout: DragSessionStackLayout>(_ type: Value.Type, layout: Layout.Type) -> some View {
        modifier(DragAndDropSession<Value, Layout>())
    }
    
    func dropArea<Value: Hashable>(
        _ type: Value.Type = Value.self,
        shouldTarget: ((_ loc: CGPoint, _ area: CGRect) -> Bool)?,
        isTargeted: @escaping (Bool) -> Void = { _ in },
        didChange: @escaping @MainActor (DropGroup<Value>) -> Void,
        didComplete: @escaping @MainActor (Bool) -> Void,
        didCancel: @escaping @MainActor () -> Void
    ) -> some View {
        modifier(DropAreaModifier(
            shouldTarget: shouldTarget,
            isTargeted: isTargeted,
            didChange: didChange,
            didComplete: didComplete,
            didCancel: didCancel
        ))
    }
    
    func dropArea<Value: Hashable>(
        _ type: Value.Type = Value.self,
        isTargeted: @escaping (Bool) -> Void = { _ in },
        didChange: @escaping @MainActor (DropGroup<Value>) -> Void,
        didComplete: @escaping @MainActor (Bool) -> Void,
        didCancel: @escaping @MainActor () -> Void
    ) -> some View {
        modifier(DropAreaModifier(
            isTargeted: isTargeted,
            didChange: didChange,
            didComplete: didComplete,
            didCancel: didCancel
        ))
    }
    
    func dragItem<Value: Hashable>(
        _ value: Value,
        didChangeDragging: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        modifier(DragItemModifier(
            value: value,
            didChangeDragging: didChangeDragging,
            view: { self }
        ))
    }
    
    func dragItem<Value: Hashable, Preview: View>(_ value: Value, @ViewBuilder preview: @escaping () -> Preview) -> some View {
        modifier(DragItemModifier(value: value, view: preview))
    }
    
}
