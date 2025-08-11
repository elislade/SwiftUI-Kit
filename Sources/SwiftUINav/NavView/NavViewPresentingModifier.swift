import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct NavViewPresentingStackModifier<Element, Destination: View>: ViewModifier {

    @Binding var data: Array<Element>
    @ViewBuilder let destination: @MainActor (Element) -> Destination
    
    private func binding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { data.indices.contains(index) },
            set: {
                if $0 == false, data.indices.contains(index) {
                    self.data.remove(at: index)
                }
            }
        )
    }
    

    func body(content: Content) -> some View {
        content
            .overlay {
                ForEach(data.indices, id: \.self){ idx in
                    Color.clear.presentationValue(
                        isPresented: binding(for: idx),
                        metadata: NavViewElementMetadata(associatedValueID: nil)
                    ) {
                        destination(data[idx])
                    }
                }
            }
    }
    
}


struct NavViewPresentingModifier<Destination: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @MainActor @ViewBuilder let destination: Destination
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                metadata: NavViewElementMetadata(associatedValueID: nil)
            ) {
                destination
            }
    }
    
}



struct NavViewPresentingOptionalModifier<Value: Hashable, Destination: View>: ViewModifier {
    
    @State private var id = UUID()
    @Binding var value: Value?
    @ViewBuilder let destination: @MainActor (Value) -> Destination
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                value: $value,
                metadata: NavViewElementMetadata(associatedValueID: nil)
            ) { v in
                destination(v)
            }
    }
    
}
