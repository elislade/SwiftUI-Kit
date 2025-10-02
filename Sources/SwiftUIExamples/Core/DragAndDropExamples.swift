import SwiftUIKit


public struct DragDropExample: View {
    
    @Namespace private var ns
    @State private var dropItemsA: [Int] = []
    @State private var dropItemsB: [Int] = []
    @State private var dragItems: [Int] = [1, 2, 3, 4, 5, 6, 7]
    
    private var filteredDragItems: [Int] {
        dragItems.filter({ !(dropItemsA.contains($0) || dropItemsB.contains($0)) })
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView("Drag & Drop"){
            VStack(spacing: 0) {
                DropStack(axis: .horizontal, data: $dropItemsA){ item in
                    Button {
                        dropItemsA.removeAll(where: { $0 == item })
                    } label: {
                        ExampleTile(item)
                    }
                    .buttonStyle(.plain)
                    .transitions(.scale(1))
                    .matchedGeometryEffect(id: item, in: ns)
                    .frame(maxWidth: 50, maxHeight: 50)
                } cursor: {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.2)
                        .frame(maxWidth: 50, maxHeight: 50)
                }
                .frame(maxHeight: 50)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                    
                    Text("Horizontal Drop Stack")
                        .opacity(dropItemsA.isEmpty ? 0.6 : 0)
                }
                
                Spacer(minLength: 5)
                
                DropStack(
                    axis: .vertical,
                    alignment: .top,
                    data: $dropItemsB,
                    removeOnCancel: true
                ){ item in
                    Button {
                        dropItemsB.removeAll(where: { $0 == item })
                    } label: {
                        ExampleTile(item)
                    }
                    .buttonStyle(.plain)
                    .transitions(.scale(1))
                    .matchedGeometryEffect(id: item, in: ns)
                    .frame(minHeight: 20, maxHeight: 50)
                } cursor: {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.2)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                    
                    Text("Vertical Drop Stack")
                        .opacity(dropItemsB.isEmpty ? 0.6 : 0)
                }
                
                Spacer(minLength: 5)
                
                HStack {
                    ForEach(filteredDragItems){ value in
                        Button {
                            if Bool.random() {
                                dropItemsA.append(value)
                            } else {
                                dropItemsB.append(value)
                            }
                        } label: {
                            ExampleTile(value)
                        }
                        .buttonStyle(.plain)
                        .transitions(.scale(1))
                        .matchedGeometryEffect(id: value, in: ns)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .dragItem(value)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                    
                    Text("Drag Stack")
                        .opacity(filteredDragItems.isEmpty ? 0.6 : 0)
                }
            }
            .dragSession(Int.self)
            .animation(.bouncy, value: dropItemsA)
            .animation(.bouncy, value: dropItemsB)
            .animation(.bouncy, value: filteredDragItems)
#if os(watchOS)
            .ignoresSafeArea()
#else
            .padding()
#endif
        }
    }
    
}


#Preview("Drag & Drop"){
    DragDropExample()
        .previewSize()
}
