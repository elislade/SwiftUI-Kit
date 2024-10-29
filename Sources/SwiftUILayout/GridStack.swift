import SwiftUI


public struct GridStack<Data: RandomAccessCollection, Label: View>: View where Data.Index == Int {
    
    let spacing: CGFloat
    let columns: Int
    let data: Data
    let label: (Data.Element?) -> Label
    
    private var rows: Int {
        Int(ceil(Double(data.count) / Double(columns)))
    }
    
    public init(
        _ data: Data,
        spacing: CGFloat = 0,
        columns: Int = 5,
        @ViewBuilder label: @escaping (Data.Element?) -> Label
    ) {
        self.spacing = spacing
        self.columns = columns
        self.data = data
        self.label = label
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self){ row in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self){ col in
                        if data.indices.contains((row * columns) + col) {
                            label(data[(row * columns) + col])
                        } else {
                            label(nil)
                        }
                    }
                }
            }
        }
    }
    
}
