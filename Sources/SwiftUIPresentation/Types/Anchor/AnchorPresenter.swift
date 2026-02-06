import SwiftUI
import SwiftUIKitCore


struct AnchorPresenter<Value: ValuePresentable, PresentationView: View>: ViewModifier {
    
    @Binding private var value: Value
    @State private var sortDate = Date()
    
    private let type: PresentedAnchorType
    private let isLeader: Bool
    private let presentation: @MainActor (Value.Presented) -> PresentationView
    
    nonisolated init(
        value: Binding<Value>,
        isLeader: Bool = false,
        type: PresentedAnchorType,
        @ViewBuilder presentation: @MainActor @escaping (Value.Presented) -> PresentationView
    ) {
        self._value = value
        self.type = type
        self.isLeader = isLeader
        self.presentation = presentation
    }
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                value: $value,
                respondsToBoundsChange: true,
                metadata: AnchorPresentationMetadata(
                    sortDate: sortDate,
                    type: type,
                    alignmentMode: .keepUntilInvalid,
                    isLeader: isLeader
                ),
                content: presentation
            )
            .onChangePolyfill(of: value.isPresented){
                //guard value.isPresented else { return }
                sortDate = Date()
            }
    }
    
}
