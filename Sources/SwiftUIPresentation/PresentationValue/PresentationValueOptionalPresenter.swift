import SwiftUI
import SwiftUIKitCore


struct PresentationValueOptionalPresenter<Value, Metadata: Equatable & Sendable, Presentation: View>: ViewModifier {
    
    @Environment(\.presentationIdentityBehaviour) private var behaviour
    let environmentRef: MainActorClosureKeyPath<EnvironmentValues>

    @State private var stableID = UUID()
    @State private var customID: UUID?
    
    @Binding var value: Value?
    let tag: String?
    var presentationRespondsToBoundsChange = false
    let metadata: Metadata
    @ViewBuilder let presentation: @MainActor (Value) -> Presentation
    
    private var id: UUID {
        behaviour.isStable ? stableID : customID ?? .init()
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Color.clear.anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
                    if let value {
                        return [.init(
                            id: id,
                            tag: tag,
                            metadata: metadata,
                            anchor: anchor,
                            includeAnchorInEquatance: presentationRespondsToBoundsChange,
                            view: { AnyView(presentation(value).routeRelay().environment(\.parent, environmentRef)) },
                            dispose: { self.value = nil },
                            envProxy: environmentRef
                        )]
                    } else {
                        return []
                    }
                }
            }
            .onChangePolyfill(of: behaviour.customHashable){
                customID = behaviour.customHashable == nil ? nil : .init()
            }
    }
    
}
