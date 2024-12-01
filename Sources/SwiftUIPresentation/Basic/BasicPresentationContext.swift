import SwiftUI
import SwiftUIKitCore

struct BasicPresentationContext: ViewModifier {

    @State private var bgInteractionPreferences: [PresentationBackgroundInteraction] = []
    @State private var bgPreferences: [PresentationBackgroundKeyValue] = []
    @State private var values: [PresentationValue<BasicPresentationMetadata>] = []
    
    private var bgIsInteractive: Bool {
        if let last = bgInteractionPreferences.last {
            last != .disabled
        } else {
            true
        }
    }
    
    nonisolated init() {
        
    }
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(!values.isEmpty)
            .disabled(!values.isEmpty && bgIsInteractive)
            .overlay {
                ZStack(alignment: values.last?.metadata.alignment ?? .bottom) {
                    Color.clear
                    
                    if let last = values.last {
                        PresentationBackground(
                            bgView: bgPreferences.last?.view,
                            bgInteraction: bgInteractionPreferences.last,
                            dismiss: last.dispose
                        )
                        .zIndex(1)
                    }
                    
                    ForEach(values, id: \.id){ value in
                        value.view()
                            .environment(\._isBeingPresented, true)
                            .environment(\.dismissPresentation, .init(id: value.id, closure: value.dispose))
                            .zIndex(3 + Double(values.firstIndex(of: value)!))
                            .accessibilityAddTraits(.isModal)
                            .accessibilityHidden(values.count > 1 ? value != values.last : false)
                    }
                }
                .onPreferenceChange(PresentationBackgroundKey.self){ bgPreferences = $0 }
                .onPreferenceChange(PresentationBackgroundInteractionKey.self){ bgInteractionPreferences = $0 }
                .animation(.fastSpringInteractive, value: values)
                .mask{
                    Rectangle().ignoresSafeArea()
                }
            }
            .onPreferenceChange(PresentationKey<BasicPresentationMetadata>.self){ values = $0 }
            .transformPreference(PresentationKey<BasicPresentationMetadata>.self){
                // don't let presentations continue up the chain if caught by this context
                $0 = []
            }
    }
}

