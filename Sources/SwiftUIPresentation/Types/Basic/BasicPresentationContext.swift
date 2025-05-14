import SwiftUI
import SwiftUIKitCore

struct BasicPresentationContext: ViewModifier {

    @State private var backdropPreference: BackdropPreference?
    @State private var willDismiss: [PresentationWillDismissAction] = []
    @State private var values: [PresentationValue<BasicPresentationMetadata>] = []
    
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
            .disabled(!values.isEmpty && backdropPreference?.isInteractive ?? true)
            .disableOnPresentationWillDismiss(!values.isEmpty)
            .overlay {
                ZStack(alignment: values.last?.metadata.alignment ?? .bottom) {
                    Color.clear
                    
                    if !values.isEmpty {
                        BackdropView(preference: backdropPreference, dismiss: dismiss)
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
                .onBackdropPreferenceChange{ backdropPreference = $0 }
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

