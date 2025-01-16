import SwiftUI


public struct DropGroup<Value: Hashable>: Hashable {
    public let locationInWindow: CGPoint
    public let items: [Value]
    
    init(locationInWindow: CGPoint, items: [Value] = []) {
        self.locationInWindow = locationInWindow
        self.items = items
    }
}

extension DropGroup: Sendable where Value: Sendable { }

struct DropArea<Value: Hashable> : Hashable, Sendable {
    
    static func == (lhs: DropArea<Value>, rhs: DropArea<Value>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    let shouldTarget: @MainActor (CGPoint) -> Bool
    let targeting: Binding<Bool>
    let didChange: @MainActor (DropGroup<Value>) -> Void
    let didComplete: @MainActor (Bool) -> Void
    let didCancel: @MainActor () -> Void
}


struct DropAreaPreference<Value: Hashable>: PreferenceKey {
    
    static var defaultValue: [DropArea<Value>] { [] }
    
    static func reduce(value: inout [DropArea<Value>], nextValue: () -> [DropArea<Value>]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct DropAreaModifier<Value: Hashable>: ViewModifier {
    
    @State private var id: UUID = UUID()
    @State private var frame = CGRect()
    @State private var targeting: Bool = false
    
    var shouldTarget: ((_ point: CGPoint, _ frame: CGRect) -> Bool)?
    var isTargeted: (Bool) -> Void = { _ in }
    var didChange: @MainActor (DropGroup<Value>) -> Void
    var didComplete: @MainActor (Bool) -> Void
    var didCancel: @MainActor () -> Void
    
    func body(content: Content) -> some View {
        content
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).rounded(.toNearestOrEven) }){ frame = $0 }
            .onChangePolyfill(of: targeting){ isTargeted(targeting) }
            .preference(
                key: DropAreaPreference<Value>.self,
                value: [
                    DropArea(
                        id: id,
                        shouldTarget: {
                            if let shouldTarget {
                                return shouldTarget($0, frame)
                            } else {
                                return frame.contains($0)
                            }
                        },
                        targeting: $targeting,
                        didChange: didChange,
                        didComplete: didComplete,
                        didCancel: didCancel
                    )
                ]
            )
    }
    
}
