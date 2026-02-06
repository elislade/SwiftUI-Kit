import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation

struct NavViewStackPresenter<Data: RangeReplaceableCollection, Destination: View> where Data.Indices == Range<Int> {

    @State private var indicesToRemove: IndexSet = .init()
    @Binding var data: Data
    @ViewBuilder let destination: @MainActor (Data.Element) -> Destination
    
}


extension NavViewStackPresenter: ViewModifier {
    
    private func binding(for index: Int) -> Binding<Bool> {
        let indices = data.indices
        return Binding(
            get: { indices.contains(index) },
            set: { [_indicesToRemove] new in
                if new == false, indices.contains(index) {
                    _indicesToRemove.wrappedValue.insert(index)
                }
            }
        )
    }
    

    func body(content: Content) -> some View {
        content.overlay {
            VStack {
                ForEach(data.indices.filter({ !indicesToRemove.contains($0) }), id: \.self){ idx in
                    Color.clear.navDestination(isPresented: binding(for: idx)){
                        destination(data[idx])
                            .onDisappear{
                                indicesToRemove.remove(idx)
                                if data.indices.contains(idx) {
                                    data.remove(at: idx)
                                }
                            }
                    }
                }
            }
        }
    }
    
}

struct NavViewPresenter<Value: ValuePresentable, Destination: View>: ViewModifier {
    
    @State private var sortDate = Date()
    @State private var id = UUID()
    @State private var source: Anchor<CGRect>?
    
    @Binding var value: Value
    @ViewBuilder let destination: @MainActor (Value.Presented) -> Destination
    
    func body(content: Content) -> some View {
        content
            .presentationSourceChange{ source = $0 }
            .presentationValue(
                value: $value,
                metadata: NavViewElementMetadata(
                    associatedValueID: id,
                    sortDate: sortDate,
                    source: source
                ),
                content: destination
            )
            .onChangePolyfill(of: value.isPresented){
                guard value.isPresented else { return }
                sortDate = Date()
            }
    }
    
}

