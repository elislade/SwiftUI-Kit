import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct NavViewPresentingStackModifier<Element: Identifiable, Destination: View>: ViewModifier {

    @Binding var data: Array<Element>
    @MainActor @ViewBuilder let destination: (Element) -> Destination
    
    private func binding(for element: Element) -> Binding<Bool> {
        .init(get: { data.contains{ $0.id == element.id } }, set: {
            if $0  == false {
                self.data.removeAll(where: { $0.id == element.id })
            }
        })
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ForEach(data){ element in
                    Color.clear.presentationValue(
                        isPresented: binding(for: element),
                        metadata: NavViewElementMetadata(associatedValueID: nil)
                    ) {
                        destination(element)
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
    @MainActor @ViewBuilder let destination: (Value) -> Destination
    @State private var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .presentationValue(
                isPresented: $isPresented,
                metadata: NavViewElementMetadata(associatedValueID: nil)
            ) {
                if let value {
                    destination(value)
                }
            }
            .onChangePolyfill(of: value, initial: true){
                isPresented = value != nil
            }
            .onChangePolyfill(of: isPresented) {
                if isPresented == false {
                    value = nil
                }
            }
    }
    
}
