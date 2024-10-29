import SwiftUI


public struct GridView<Data: RandomAccessCollection, Label: View>: View where Data.Index == Int, Data.Element : Identifiable {

    let spacing: CGFloat
    let columns: Int
    let data: Data
    let label: (Data.Element) -> Label
    
    public init(
        _ data: Data,
        spacing: CGFloat = 0,
        columns: Int = 5,
        @ViewBuilder label: @escaping (Data.Element) -> Label
    ) {
        self.spacing = spacing
        self.columns = max(columns, 1)
        self.data = data
        self.label = label
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(data){ item in
                label(item)
                    .alignmentGuide(.top) {
                        let i = Double(data.firstIndex(where: { $0.id == item.id })!)
                        let row : Double = floor(i / Double(columns))
                        return -(($0.height + spacing) * row)
                    }
                    .alignmentGuide(.leading) {
                        let i = Double(data.firstIndex(where: { $0.id == item.id })! + 1)
                        let row : Double = floor((i - 1) / Double(columns))
                        let columns = Double(columns)
                        let column = i > columns ? ((i / columns) - row) * columns : i
                        return -(($0.width + spacing) * round(column))
                    }
            }
        }
    }
    
}

