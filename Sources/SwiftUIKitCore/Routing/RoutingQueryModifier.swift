import SwiftUI


struct RoutingQueryModifier {
    
    @State private var id = UUID()
    
    let keys: [String]
    let action: ([String]) async -> Void
    
    func body(content: Content) -> some View {
        content.background{
            Color.clear.preference(key: RoutePreferenceKey.self, value: [
                .init(
                    id: id,
                    isActive: false,
                    handle: { comps in
                        if let last = comps.last?.params, keys.allSatisfy({ last.keys.contains($0) }) {
                            await action(keys.compactMap{ last[$0] })
                            return true
                        }
                        return false
                    }
                )
            ])
        }
    }
    
}

extension RoutingQueryModifier: ViewModifier {}
