import SwiftUI
import SwiftUIKitCore


struct PresentationValueOptionalPresenter<Value, Metadata: Equatable & Sendable, Presentation: View>: ViewModifier {
    
    @Environment(\.presentationIdentityBehaviour) private var behaviour
    let environmentRef: ClosureKeyPath<EnvironmentValues>

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
                            view: { AnyView(presentation(value)) },
                            dispose: {
                                DispatchQueue.main.async {
                                    self.value = nil
                                }
                            },
                            requestIDChange: { id in
                                DispatchQueue.main.async {
                                    stableID = id ?? .init()
                                }
                            },
                            envProxy: environmentRef
                        )]
                    } else {
                        return []
                    }
                }
            }
            .onChange(of: behaviour.customHashable){
                customID = $0 == nil ? nil : .init()
            }
    }
    
}
