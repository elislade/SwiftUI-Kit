import SwiftUI
import SwiftUIKitCore

struct BasicPresentationContext: ViewModifier {

    @State private var bgInteractionPreferences: [PresentationBackgroundInteraction] = []
    @State private var bgPreferences: [PresentationBackgroundKeyValue] = []
    @State private var willDismiss: [PresentationWillDismissAction] = []
    @State private var values: [PresentationValue<BasicPresentationMetadata>] = []
    
    private var bgIsInteractive: Bool {
        if let last = bgInteractionPreferences.last {
            last != .disabled
        } else {
            true
        }
    }
    
    private func dismiss() {
        guard let value = values.last else { return }
        
        for action in willDismiss {
            action()
        }
        
        value.dispose()
    }
    
    nonisolated init() {}
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(!values.isEmpty)
            .disabled(!values.isEmpty && bgIsInteractive)
            .disableOnPresentationWillDismiss(!values.isEmpty)
            .overlay {
                ZStack(alignment: values.last?.metadata.alignment ?? .bottom) {
                    Color.clear
                    
                    if !values.isEmpty {
                        PresentationBackground(
                            bgView: bgPreferences.last?.view(),
                            bgInteraction: bgInteractionPreferences.last,
                            dismiss: dismiss
                        )
                        .zIndex(2 + Double(values.count - 1))
                    }
                    
                    ForEach(values, id: \.id){ value in
                        value.view()
                            .environment(\._isBeingPresented, true)
                            .environment(\.dismissPresentation, .init(id: value.id, closure: dismiss))
                            .zIndex(2 + Double(values.firstIndex(of: value)!))
                            .accessibilityAddTraits(.isModal)
                            .accessibilityHidden(values.count > 1 ? value != values.last : false)
                            .disableOnPresentationWillDismiss(values.last != value)
                            .isBeingPresentedOn(value != values.last)
                        
                        
                    }
                }
                .onPreferenceChange(PresentationBackgroundKey.self){
                    _bgPreferences.wrappedValue = $0
                }
                .onPreferenceChange(PresentationBackgroundInteractionKey.self){
                    _bgInteractionPreferences.wrappedValue = $0
                }
                .animation(.smooth, value: values)
                .mask{
                    Rectangle().ignoresSafeArea()
                }
            }
            .onPreferenceChange(PresentationKey<BasicPresentationMetadata>.self){
                _values.wrappedValue = $0
            }
            .transformPreference(PresentationKey<BasicPresentationMetadata>.self){ $0 = [] }
            .presentationMatchContext()
            .onPreferenceChange(PresentationWillDismissPreferenceKey.self){ actions in
                _willDismiss.wrappedValue = actions
            }
                
    }
}

