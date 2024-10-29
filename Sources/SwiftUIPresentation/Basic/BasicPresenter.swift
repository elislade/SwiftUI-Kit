import SwiftUI

struct BasicPresenter<Presentation: View>: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPresented: Bool
    
    var alignment: Alignment = .bottom
    let presentation: Presentation
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                metadata: BasicPresentationMetadata(alignment: alignment)
            ) {
                presentation
            }
    }
    
}
