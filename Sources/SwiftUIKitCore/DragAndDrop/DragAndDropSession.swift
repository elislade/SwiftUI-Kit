import SwiftUI


struct DragAndDropSession<Value: Hashable & Sendable, Layout: DragSessionStackLayout> : ViewModifier {
    
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var dragAndDropSession
    
    @State private var dropAreas: [DropArea<Value>] = []
    @State private var dragItems: [DragItem<Value>] = []
    
    @State private var frame: CGRect = .zero
    @State private var dropAreasEntered: Set<UUID> = []
    @State private var location: CGPoint?
    @State private var itemsAreInDropArea: Bool = false
    
    #if os(iOS) || os(watchOS)
    private let eventOffset: Double = 50
    #else
    private let eventOffset: Double = 0
    #endif
    
   // private let layout = Layout(isExpanded: false)
    
    private func handle(location: CGPoint) {
        guard !dragItems.isEmpty else { return }
        
        var inDrop = false
        
        for area in dropAreas {
            let targeting = area.shouldTarget(location)
            area.targeting.wrappedValue = targeting
            
            if targeting {
                inDrop = true
                dropAreasEntered.insert(area.id)
            }
            
            if targeting, !dragItems.isEmpty {
                area.didChange(DropGroup(
                    locationInWindow: location,
                    items: dragItems.map(\.value)
                ))
            }
        }
        
        itemsAreInDropArea = inDrop
    }
    
    private func end() {
        for item in dragItems {
            item.dispose()
        }
        
        for area in dropAreas.filter({ dropAreasEntered.contains($0.id) }) {
            if area.targeting.wrappedValue {
                area.didComplete(true)
                area.targeting.wrappedValue = false
            } else {
                area.didCancel()
            }
        }

        self._dragItems.wrappedValue.removeAll()
        self.dropAreasEntered.removeAll()
    }
    
    nonisolated private func update(_ items: [DragItem<Value>]) {
        withAnimation(.bouncy){
            _dragItems.wrappedValue = items
        }
    }
    
    func body(content: Content) -> some View {
        content
            .preferredParentGestureMask(dragItems.isEmpty ? nil : .subviews)
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).rounded(.toNearestOrEven) }){ frame = $0 }
            .onPreferenceChange(DropAreaPreference<Value>.self){
                _dropAreas.wrappedValue = $0
            }
            .onWindowDrag { evt in
                if evt.phase == .ended {
                    self.end()
                    return
                }
                
                if let location = evt.locations.first {
                    //layout.location = location
                    let l = location.applying(.init(translationX: 0, y: -eventOffset))
                    self.location = l
                    handle(location: l)
                }
            }
            .onChangePolyfill(of: scenePhase){
                self.end()
            }
            .overlay{
                ZStack {
                    Color.clear
 
                    let location = (self.location ?? .zero).applying(.init(translationX: -frame.minX, y: -frame.minY))
                    
                    ForEach(dragItems, id: \.self){ item in
                        Layout(isExpanded: itemsAreInDropArea && dragItems.count > 1, location: location).layoutItem(
                            item.view(),
                            index: dragItems.firstIndex(of: item)!,
                            count: dragItems.count
                        )
                        .offset(x: location.x - item.origin.x, y: location.y - item.origin.y)
                        .position(item.origin)
                    }
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()
                .animation(.bouncy, value: dragItems)
                .animation(.interactiveSpring, value: location)
            }
            .environment(\.dragSessionNamspace, dragAndDropSession)
            .environment(\.dragItemAction, .init(namespace: dragAndDropSession){
                self._dragItems.wrappedValue.append($0)
                
                if let location {
                    handle(location: location.applying(.init(translationX: 0, y: -eventOffset)))
                }
            })
    }
    
}


struct DragSessionNamespaceKey: EnvironmentKey {
    static var defaultValue: Namespace.ID? { nil }
    
    typealias Value = Namespace.ID?
    
}


extension EnvironmentValues {
    
    var dragSessionNamspace: Namespace.ID? {
        get { self[DragSessionNamespaceKey.self] }
        set { self[DragSessionNamespaceKey.self] = newValue }
    }
    
    var dragItemAction: DragItemAction? {
        get { self[TestDragItemActionKey.self] }
        set { self[TestDragItemActionKey.self] = newValue }
    }
    
}


struct TestDragItemActionKey: EnvironmentKey {
    
    static var defaultValue: DragItemAction? { nil }
    
}

struct DragItemAction: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.namespace == rhs.namespace
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(namespace)
    }
    
    private let namespace: Namespace.ID
    private let wrapped: (DragItem<AnyHashable>) -> Void
    
    init<Value: Hashable>(namespace: Namespace.ID, _ wrapped: @escaping (DragItem<Value>) -> Void) {
        self.namespace = namespace
        self.wrapped = {
            if let value = $0.value.base as? Value {
                wrapped(.init(
                    id: $0.id,
                    origin: $0.origin,
                    value: value,
                    view: $0.view,
                    dispose: $0.dispose
                ))
            }
        }
    }
    
    func callAsFunction<Value: Hashable>(_ item: DragItem<Value>) {
        wrapped(.init(
            id: item.id,
            origin: item.origin,
            value: item.value,
            view: item.view,
            dispose: item.dispose
        ))
    }
    
}
