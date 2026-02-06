//import SwiftUI
//import SwiftUIPresentation
//
//struct NavViewDestinationValueModifier<Value: Hashable, Destination: View> {
//    
//    @Environment(\.destinationNavValue) private var value
//    
//    @State private var matches: [PresentationValue<NavViewElementMetadata>] = []
//    
//    let destination: @MainActor (Value) -> Destination
//    
//}
//
//extension NavViewDestinationValueModifier: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content.overlay{
//            Color.clear
//                .onChangePolyfill(of: value){
//                    guard
//                        let u = value,
//                        let v = u.value as? Value, !matches.contains(where: { $0.id == u.id })
//                    else { return }
//                    
//                    let exists = NavValueAssociationCache.shared.values.contains(u.id)
//                    guard exists == false else { return }
//                    
//                    NavValueAssociationCache.shared.addValue(u.id)
//                    
//                    matches.append(.init(
//                        id: .init(),
//                        metadata: NavViewElementMetadata(associatedValueID: u.id, sortDate: Date()),
//                        anchor: ,
//                        view: destination(v),
//                        dispose: {
//                            NavValueAssociationCache.shared.removeValue(u.id)
//                            matches.removeAll(where: { $0.associatedValueID == u.id })
//                        },
//                        environment: .init(.init())
//                    ))
//                }
//        }
//    }
//    
//}
//
//@MainActor class NavValueAssociationCache {
//    
//    static let shared = NavValueAssociationCache()
//    
//    private init(){}
//    
//    private(set) var values: Set<UUID> = []
//    
//    func addValue(_ value: UUID) {
//        values.insert(value)
//    }
//    
//    func removeValue(_ value: UUID) {
//        values.remove(value)
//    }
//    
//}
//
//
//struct NavViewDestinationValueKey: PreferenceKey {
//    
//    static var defaultValue: [NavViewDestinationValue] { [] }
//    
//    static func reduce(value: inout [NavViewDestinationValue], nextValue: () -> [NavViewDestinationValue]) {
//        value.append(contentsOf: nextValue())
//    }
//    
//}
//
//
//struct NavViewDestinationValue: Equatable {
//    
//    static func == (lhs: NavViewDestinationValue, rhs: NavViewDestinationValue) -> Bool {
//        lhs.id == rhs.id && lhs.value == rhs.value
//    }
//    
//    let id: UUID
//    let value: AnyHashable
//    let dispose: () -> Void
//    
//}

//
//extension EnvironmentValues {
//    
//    var destinationNavValue: NavViewDestinationValue? {
//        get { self[NavViewPendingDestinationValue.self] }
//        set { self[NavViewPendingDestinationValue.self] = newValue }
//    }
//    
//}


//struct NavViewPendingDestinationValue: EnvironmentKey {
//    
//    static var defaultValue: NavViewDestinationValue? { nil }
//    
//}
