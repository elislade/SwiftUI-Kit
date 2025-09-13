import SwiftUI


struct RoutingPathModifier {
    
    @State private var id = UUID()
    @State private var wasActivated = false
    @State private var children: [RoutePreference] = []
    
    let path: String
    let action: () async -> Void
    var other: (() -> Void)? = nil
    
    @discardableResult private func handle(_ comps: [LinkComponent]) async -> Bool {
        guard !comps.isEmpty, !children.isEmpty else { return false }
        var foundMatch: Bool = false
        
        for child in children {
            // if a match was found exhause others that didn't match just in case they activated on a previous link pass
            if foundMatch {
                await _ = child.handle([])
            } else if await child.handle(Array(comps.dropFirst())) {
                foundMatch = true
            }
        }
        
        return foundMatch
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
                                    if wasActivated {
                                        await exhaustOtherChildren()
                                    }
                                    await action()
                                    wasActivated = true
                                    return true
                                }
                                
                                let wasHandled = await handle(comps)
                                
                                // Only proceed if another next match does not already exists.
                                if !wasHandled {
                                    await action()
                                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
                                    let handled = await handle(comps)
                                    wasActivated = handled
                                    return handled
                                } else {
                                    wasActivated = true
                                }
                                
                                return wasHandled
                            }
                            
                            if wasActivated {
                                await exhaustOtherChildren()
                                other?()
                                wasActivated = false
                            }
                            
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
