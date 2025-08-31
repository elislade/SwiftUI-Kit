import SwiftUI

struct BasicPresenter<Presentation: View>: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPresented: Bool
    
    let alignment: Alignment
    @ViewBuilder let presentation: @MainActor () -> Presentation
    
    nonisolated init(
        isPresented: Binding<Bool>,
        alignment: Alignment = .bottom,
        @ViewBuilder presentation: @MainActor @escaping () -> Presentation
    ) {
        self._isPresented = isPresented
        self.alignment = alignment
        self.presentation = presentation
    }
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                metadata: BasicPresentationMetadata(alignment: alignment)
            ) {
                presentation()
            }
    }
    
}


struct BasicPresenterOptional<Presentation: View, Value: Hashable> {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var value: Value?
    
    let alignment: Alignment
    @ViewBuilder let presentation: @MainActor (Value) -> Presentation
    
    nonisolated init(
        value: Binding<Value?>,
        alignment: Alignment = .bottom,
        @ViewBuilder presentation: @MainActor @escaping (Value) -> Presentation
    ) {
        self._value = value
        self.alignment = alignment
        self.presentation = presentation
    }

}


extension BasicPresenterOptional: ViewModifier {
    
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
