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
        ZStack(alignment: .bottom) {
            Color.clear
            
            VStack(spacing: 5) {
                Spacer()
                
                Text("Horizontal Drop Stack").opacity(0.6)
                
                DropStack(
                    axis: .horizontal,
                    data: $dropItemsA
                ){ item in
                    Button(action: { dropItemsA.removeAll(where: { $0 == item }) }){
                        ExampleTile(item)
                    }
                    .buttonStyle(.plain)
                    .transitions(.scale(1))
                    .matchedGeometryEffect(id: item, in: ns)
                    .frame(maxWidth: 80, maxHeight: 80)
                } cursor: {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.2)
                        .frame(maxWidth: 80, maxHeight: 80)
                }
                .frame(height: 80)
                .padding(10)
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                }
                
                Spacer()
                
                Text("Vertical Drop Stack").opacity(0.6)
                
                DropStack(
                    axis: .vertical,
                    alignment: .top,
                    data: $dropItemsB,
                    removeOnCancel: true
                ){ item in
                    Button(action: { dropItemsB.removeAll(where: { $0 == item }) }){
                        ExampleTile(item)
                    }
                    .buttonStyle(.plain)
                    .transitions(.scale(1))
                    .matchedGeometryEffect(id: item, in: ns)
                    .frame(maxHeight: 80)
                } cursor: {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.2)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                }
                .padding(10)
                .frame(minHeight: 200)
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                }
                
                Spacer()
                
                Text("Drag Stack").opacity(0.6)
                
                HStack {
                    ForEach(filteredDragItems){ value in
                        Button(action: {
                            if Bool.random() {
                                dropItemsA.append(value)
                            } else {
                                dropItemsB.append(value)
                            }
                        }){
                            ExampleTile(value)
                        }
                        .buttonStyle(.plain)
                        .transitions(.scale(1))
                        .matchedGeometryEffect(id: value, in: ns)
                        .frame(maxWidth: 80, maxHeight: 80)
                        .dragItem(value)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .padding(10)
                .background{
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.secondary)
                        .opacity(0.3)
                }
                
                Spacer()
                
                ExampleTitle("Drag & Drop")
            }
            .padding()
            .dragSession(Int.self)
        }
        .animation(.bouncy, value: dropItemsA)
        .animation(.bouncy, value: dropItemsB)
        .animation(.bouncy, value: filteredDragItems)
    }
    
}


#Preview("Drag & Drop"){
    DragDropExample()
        .previewSize()
}
