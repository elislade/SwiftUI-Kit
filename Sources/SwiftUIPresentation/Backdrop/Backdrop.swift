import SwiftUI
import SwiftUIKitCore


extension View {
    
    nonisolated public func presentationBackdrop(
        _ interaction: BackdropInteraction? = .touchEndedDismiss,
        @ViewBuilder content: @MainActor @escaping () -> some View)
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
    
    nonisolated public func presentationBackdrop(_ interaction: BackdropInteraction?) -> some View {
        InlineState(UUID()){ id in
            self.preference(
                key: BackdropPreferenceKey.self,
                value: .init(id: id, interaction: interaction, view: { AnyView(EmptyView()) })
            )
        }
    }
    
    nonisolated public func onPresentationBackdropChange(perform action: @escaping (BackdropPreference?) -> Void) -> some View {
        onPreferenceChange(BackdropPreferenceKey.self, perform: action)
            .preferenceKeyReset(BackdropPreferenceKey.self)
    }
    
}
