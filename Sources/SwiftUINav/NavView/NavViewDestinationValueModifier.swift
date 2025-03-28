import SwiftUI
import SwiftUIPresentation

struct NavViewDestinationValueModifier<Value: Hashable, Destination: View>: ViewModifier {
    
    @Environment(\.destinationNavValue) private var value
    
    //@State private var id = UUID()
    @State private var matches: [NavViewElement] = []
    @State private var matchesB: [PresentationValue<NavViewElementMetadata>] = []
    
    let destination: (Value) -> Destination
    
    func body(content: Content) -> some View {
        content.overlay{
            Color.clear
                .anchorPreference(key: PresentationKey<NavViewElementMetadata>.self, value: .bounds){ anchor in
                    []
                }
                .onChangePolyfill(of: value){
                    guard
                        let u = value,
                        let v = u.value as? Value, !matches.contains(where: { $0.id == u.id })
                    else { return }
                    
                    Task {
                        let exists = await NavValueAssociationCache.shared.values.contains(u.id)
                        guard exists == false else { return }
                        await NavValueAssociationCache.shared.addValue(u.id)
                        
                        matches.append(.init(
                            id: .init(),
                            view: AnyView(destination(v)),
                            associatedValueID: u.id,
                            dispose: {
                                Task {
                                    await NavValueAssociationCache.shared.removeValue(u.id)
                                    matches.removeAll(where: { $0.associatedValueID == u.id })
                                }
                            }
                        ))
                    }
                }
        }
    }
    
}



actor NavValueAssociationCache {
    
    static let shared = NavValueAssociationCache()
    
    private init(){}
    
    private(set) var values: Set<UUID> = []
    
    func addValue(_ value: UUID) {
        values.insert(value)
    }
    
    func removeValue(_ value: UUID) {
        values.remove(value)
    }
}
