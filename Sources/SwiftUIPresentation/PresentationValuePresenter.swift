import SwiftUI
import SwiftUIKitCore


struct PresentationValuePresenter<Metadata: Equatable, Presentation: View>: ViewModifier {
    
    let environment: EnvironmentValues
    
    @State private var stableID = UUID()
    @State private var customID: UUID?
    
    let behaviour: PresentationIdentityBehaviour
    @Binding var isPresented: Bool
    let tag: String?
    var presentationRespondsToBoundsChange = false
    let metadata: Metadata
    @ViewBuilder let presentation: Presentation
    
    func body(content: Content) -> some View {
        content.overlay {
            Color.clear.anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
                isPresented ? [.init(
                    id: behaviour.isStable ? stableID : customID ?? .init(),
                    tag: tag,
                    metadata: metadata,
                    anchor: anchor,
                    includeAnchorInEquatance: presentationRespondsToBoundsChange,
                    view: AnyView(presentation),
                    dispose: { isPresented = false },
                    requestIDChange: { id in
                        stableID = id ?? .init()
                    },
                    envProxy: ClosureKeyPath(environment)
                )] : []
            }
        }
        .onChange(of: behaviour.customHashable){
            customID = $0 == nil ? nil : .init()
        }
    }
    
}


struct PresentationOptionalValuePresenter<Value, Metadata: Equatable, Presentation: View>: ViewModifier {
    
    let environment: EnvironmentValues
    let behaviour: PresentationIdentityBehaviour
    @State private var stableID = UUID()
    @State private var customID: UUID?
    
    @Binding var value: Value?
    let tag: String?
    var presentationRespondsToBoundsChange = false
    let metadata: Metadata
    
    @ViewBuilder let presentation: (Value) -> Presentation
    
    func body(content: Content) -> some View {
        content
            .anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
                if let value {
                    return [.init(
                        id: behaviour.isStable ? stableID : customID ?? .init(),
                        tag: tag,
                        metadata: metadata,
                        anchor: anchor,
                        includeAnchorInEquatance: presentationRespondsToBoundsChange,
                        view: AnyView(presentation(value)),
                        dispose: { self.value = nil },
                        requestIDChange: { id in
                            stableID = id ?? .init()
                        },
                        envProxy: ClosureKeyPath(environment)
                    )]
                } else {
                    return []
                }
            }
            .onChange(of: behaviour.customHashable){
                customID = $0 == nil ? nil : .init()
            }
    }
    
}

//struct PresentationValuesPresenter<Metadata: Equatable, Presentation: View>: ViewModifier {
//
//    @State private var id = UUID()
//    @Binding var metadata: [Metadata]
//
//    let tag: String?
//    @ViewBuilder let presentation: Presentation
//
//    func body(content: Content) -> some View {
//        content.anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
//            if let metadata {
//                return [.init(
//                    id: id,
//                    tag: tag,
//                    metadata: metadata,
//                    anchor: anchor,
//                    view: AnyView(presentation),
//                    dispose: { self.metadata = nil }
//                )]
//            } else {
//                return []
//            }
//        }
//    }
//
//}
