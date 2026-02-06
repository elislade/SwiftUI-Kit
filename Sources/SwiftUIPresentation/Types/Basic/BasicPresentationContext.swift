import SwiftUI
import SwiftUIKitCore

struct BasicPresentationContext: ViewModifier {

    typealias Metadata = BasicPresentationMetadata
    
    @State private var isBeingPresentedOn: Bool = false
    @State private var values: [PresentationValue<Metadata>] = []
    
    nonisolated init() {}
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(isBeingPresentedOn)
            //.disabled(!values.isEmpty && backdropPreference?.isInteractive ?? true)
            .accessibilityHidden(!values.isEmpty)
            .coordinatedGesture(DragGesture.Value.self)
            .overlay {
                if !values.isEmpty {
                    InnerView(
                        values: values
                    ){
                       isBeingPresentedOn = true
                    }
                    .transition(.identity)
                    .onDisappear{
                        isBeingPresentedOn = false
                    }
                }
            }
            .presentationHandler(Metadata.self){ values = $0 }
            .gestureCoordinator(DragGesture.Value.self)
    }
    
    
    struct InnerView: View {
        
        @State private var backdropPreference: BackdropPreference?
        @State private var presented: Set<UniqueID> = []
        @State private var hasPresented: Set<UniqueID> = []
        
        let values: [PresentationValue<Metadata>]
        let didPresent: () -> Void
        
        private func dismissAll() {
            for value in values.reversed() {
                value.dispose()
                presented.remove(value.id)
            }
//            guard let value = values.last else { return }
//            presented.remove(value.id)
//            value.dispose()
        }
        
        var body: some View {
            let hasPresentedValues = values.filter({ hasPresented.contains($0.id) })
            
            Color.clear.overlay{
                if !presented.isEmpty {
                    BackdropView(
                        preference: backdropPreference,
                        dismiss: dismissAll
                    )
                    .zIndex(2 + Double(values.filter({ presented.contains($0.id) }).count - 1))
                    .transition(.asymmetric(
                        insertion: (.opacity + .hitTestingDisabled).animation(.smooth),
                        removal: (.opacity + .hitTestingDisabled).animation(.smooth.delay(0.25))
                    ))
                }
                
                ForEach(values){ value in
                    Color.clear.overlay(alignment: value.alignment) {
                        if presented.contains(value.id) {
                            value.view
                                .environment(\._isBeingPresented, true)
                        } else {
                            value.view
                                .hidden()
                                .presentationMatchDisabled()
                                .onDisappear{
                                    // using the inverse to gauge transition animation completion has a drawback that asymetric transitions will use opposite animations
                                    if presented.count == 1 {
                                        didPresent()
                                    }
                                    hasPresented.insert(value.id)
                                }
                        }
                    }
                    .animation(.smooth, value: value.alignment)
                    .onChangePolyfill(of: value.wantsDisposal){
                        if value.wantsDisposal {
                            presented.remove(value.id)
                        }
                    }
                    .presentationDismissHandler {
                        value.dispose()
                        presented.remove(value.id)
                    }
                    .accessibilityAddTraits(.isModal)
                    .accessibilityHidden(values.count > 1 ? value != values.last : false)
                    .isBeingPresentedOn(value != hasPresentedValues.last && value != values.last)
                    .zIndex((2 + Double(values.firstIndex(of: value)!)))
                    .onAppear{ presented.insert(value.id) }
                    .onDisappear{ presented.remove(value.id) }
                }
            }
            .onPresentationBackdropChange{ backdropPreference = $0 }
            .presentationDismissHandler(.context) {
                dismissAll()
            }
        }
        
    }
    
}
