import SwiftUI


struct RoutingPathModifier {
    
    @State private var id = UUID()
    @State private var children: [RoutePreference] = []
    
    let path: String
    let action: () async -> Void
    var other: (() -> Void)? = nil
    
    @discardableResult private func handle(_ comps: [LinkComponent]) async -> Bool {
        guard !comps.isEmpty, !children.isEmpty else { return false }

        for child in children {
            if await child.handle(Array(comps.dropFirst())) {
                return true
            }
        }
        
        return false
    }
    
    private func exhaustOtherChildren() async {
        for child in children {
            _ = await child.handle([])
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 60)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(RoutePreferenceKey.self){
                children = $0
            }
            .resetPreference(RoutePreferenceKey.self)
            .background{
                Color.clear.preference(key: RoutePreferenceKey.self, value: [
                    .init(
                        id: id,
                        handle: { comps in
                            if let first = comps.first?.path, (first == path || first == "*") {
                                if comps.count == 1 {
                                    await exhaustOtherChildren()
                                    await action()
                                    return true
                                }
                                
                                let wasHandled = await handle(comps)
                                
                                // Only proceed if another next match does not already exists.
                                if !wasHandled {
                                    await action()
                                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
                                    return await handle(comps)
                                }
                                
                                return wasHandled
                            }

                            await exhaustOtherChildren()
                            other?()
                            return false
                        }
                    )
                ])
            }
    }
    
}

extension RoutingPathModifier: ViewModifier {}

struct RoutePreference: Equatable {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let handle: ([LinkComponent]) async -> Bool
    
}


struct RoutePreferenceKey: PreferenceKey {
    
    typealias Value = [RoutePreference]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
