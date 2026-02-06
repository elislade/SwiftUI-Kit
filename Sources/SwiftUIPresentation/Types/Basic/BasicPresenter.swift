import SwiftUI

struct BasicPresenter<Value: ValuePresentable, Presentation: View>: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var value: Value
    
    private let alignment: Alignment
    @ViewBuilder let presentation: @MainActor (Value.Presented) -> Presentation
    
    nonisolated init(
        value: Binding<Value>,
        alignment: Alignment = .bottom,
        @ViewBuilder presentation: @MainActor @escaping (Value.Presented) -> Presentation
    ) {
        self._value = value
        self.alignment = alignment
        self.presentation = presentation
    }
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                value: $value,
                metadata: BasicPresentationMetadata(alignment: alignment)
            ) {
                presentation($0)
            }
    }
    
}
