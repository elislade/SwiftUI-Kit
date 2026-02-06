import SwiftUI


struct RoutingPathModifier {
    
    @Environment(\.routeDelay) private var delay
    
    @State private var id = UUID()
    @State private var internallyActive = false
    @State private var children: [RoutePreference] = []
    
    private let path: String
    private let externallyActive: Binding<Bool>?
    private let prepareToActivate: (() async -> Void)?
    private let other: (() -> Void)?
    
    private var activeBinding: Binding<Bool> {
        externallyActive ?? $internallyActive
    }
    
    private var isActive: Bool {
        get { activeBinding.wrappedValue }
        nonmutating set {
            activeBinding.wrappedValue = newValue
        }
    }
    
    init(
        path: String,
        isActive: Binding<Bool>? = nil,
        action: (() async -> Void)? = nil,
        other: (() -> Void)? = nil
    ) {
        self.path = path
        self.externallyActive = isActive
        self.prepareToActivate = action
        self.other = other
    }
    
    private var childIsActive: Bool {
        for child in children {
            if child.isActive { return true }
        }
        return false
    }
    
    @MainActor @discardableResult private func handle(_ comps: [LinkComponent]) async -> Bool {
        guard !comps.isEmpty, !children.isEmpty else { return false }
        var foundMatch: Bool = false
        
        for child in children {
            // if a match was found deactivate other active link paths.
            if foundMatch {
                if child.isActive {
                    await _ = child.handle([])
                }
            } else if await child.handle(Array(comps.dropFirst())) {
                foundMatch = true
            }
        }
        
        return foundMatch
    }
    
    @MainActor private func deactivateActiveChildren() async {
        for child in children {
            if !child.isActive { continue }
            // sending empty link components is the same as deactivating as no path should match.
            _ = await child.handle([])
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 60)
        }
    }
    
    @MainActor private func handleComponents(_ comps: [LinkComponent]) async -> Bool {
        if let first = comps.first?.path, (first == path || first == "*") {
            if comps.count == 1 {
                if isActive || childIsActive {
                    await deactivateActiveChildren()
                }
                await prepareToActivate?()
                isActive = true
                return true
            }
            
            let wasHandled = await handle(comps)
            
            // Only proceed if another next match does not already exists and a prepare to activate is available
            if !wasHandled {
                if let prepareToActivate {
                    await prepareToActivate()
                } else {
                    isActive = true
                }
                try? await Task.sleep(nanoseconds: nanoseconds(seconds: delay))
                // Second pass after waiting for view to prepare activation. Waiting a third of a second seems long but is here to not overwhelm the user. With the delay the user can follow the steps of what was routed to and not have it happen all really quickly.
                let handled = await handle(comps)
                isActive = handled
                return handled
            }
            
            isActive = wasHandled
            
            return wasHandled
        }
        
        // If this path is active and no longer matches, deactivate.
        if isActive || childIsActive {
            await deactivateActiveChildren()
            other?()
            isActive = false
        }
        
        return false
    }
    
}


extension RoutingPathModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(RoutePreferenceKey.self){ children = $0 }
            .preferenceKeyReset(RoutePreferenceKey.self)
            .background{
                Color.clear.preference(key: RoutePreferenceKey.self, value: [
                    .init(
                        id: id,
                        isActive: isActive || childIsActive,
                        handle: { comps in
                            await handleComponents(comps)
                        }
                    )
                ])
            }
    }
    
}

struct RoutePreference: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.isActive == rhs.isActive
    }
    
    let id: UUID
    let isActive: Bool
    let handle: ([LinkComponent]) async -> Bool
    
}


struct RoutePreferenceKey: PreferenceKey {
    
    typealias Value = [RoutePreference]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
