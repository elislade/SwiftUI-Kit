import SwiftUI
import SwiftUIKitCore


struct PresentationValueBoolPresenter<Metadata: Equatable & Sendable, Presentation: View>: ViewModifier {
    
    @Environment(\.presentationIdentityBehaviour) private var behaviour
    let environmentRef: ClosureKeyPath<EnvironmentValues>
    
    @State private var stableID = UUID()
    @State private var customID: UUID?
    
    @Binding var isPresented: Bool
    let tag: String?
    var presentationRespondsToBoundsChange = false
    let metadata: Metadata
    @ViewBuilder let presentation: @MainActor () -> Presentation
    
    private var id: UUID {
        behaviour.isStable ? stableID : customID ?? .init()
    }
    
    func body(content: Content) -> some View {
        content.overlay {
            Color.clear.anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
                isPresented ? [.init(
                    id: id,
                    tag: tag,
                    metadata: metadata,
                    anchor: anchor,
                    includeAnchorInEquatance: presentationRespondsToBoundsChange,
                    view: { AnyView(presentation()) },
                    dispose: {
                        DispatchQueue.main.async {
                            isPresented = false
                        }
                    },
                    requestIDChange: { id in
                        DispatchQueue.main.async {
                            stableID = id ?? .init()
                        }
                    },
                    envProxy: environmentRef
                )] : []
            }
        }
        .onChange(of: behaviour.customHashable){
            customID = $0 == nil ? nil : .init()
        }
    }
    
}
