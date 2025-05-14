import SwiftUI
import SwiftUIKitCore


public extension View {
    
    func presentationBackdrop<C: View>(
        _ interaction: BackdropInteraction = .touchEndedDismiss,
        @ViewBuilder content: @escaping () -> C)
    -> some View {
        InlineState(UUID()){ id in
            self.preference(
                key: BackdropPreferenceKey.self,
                value: .init(id: id, interaction: interaction){
                    AnyView(content())
                }
            )
        }
    }
    
    func presentationBackdrop(_ interaction: BackdropInteraction) -> some View {
        InlineState(UUID()){ id in
            self.preference(
                key: BackdropPreferenceKey.self,
                value: .init(id: id, interaction: interaction, view: { AnyView(EmptyView()) })
            )
        }
    }
    
    func onBackdropPreferenceChange(perform action: @escaping (BackdropPreference?) -> Void) -> some View {
        onPreferenceChange(BackdropPreferenceKey.self, perform: action)
            .onDisappear{ action(nil) }
    }
    
}
