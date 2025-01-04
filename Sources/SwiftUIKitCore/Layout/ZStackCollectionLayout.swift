import SwiftUI


public struct ZStackCollectionLayout<Data, ID, Content: View, Layout: RelativeCollectionLayoutModifier>: View
    where ID == Data.Element.ID, Data : RandomAccessCollection, Data.Element : Identifiable, Data.Index == Int
{
    
    let layout: Layout
    let data: Data
    @ViewBuilder let content: (Data.Element) -> Content
    
    public init(
        _ layout: Layout,
        data: Data,
        content: @escaping (Data.Element) -> Content
    ) {
        self.layout = layout
        self.data = data
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            Color.clear
            
            ZStack {
                ForEach(data){ item in
                    layout.layoutItem(
                        AnyView(content(item)),
                        index: data.firstIndex(where: { $0.id == item.id })!,
                        count: data.count
                    )
                }
            }
        }
    }
    
}
