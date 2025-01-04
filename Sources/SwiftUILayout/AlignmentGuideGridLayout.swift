import SwiftUI
import SwiftUIKitCore


public struct AlignmentGuideGrid<Data: RandomAccessCollection & Sendable, Label: View>: View where Data.Index == Int, Data.Element : Identifiable & Sendable {

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
    
    private var layout: some RelativeCollectionLayoutModifier {
        AlignmentGuideGridLayout(spacing: spacing, columns: columns)
    }
    
    public var body: some View {
        ZStackCollectionLayout(layout, data: data, content: label)
    }
    
}


public struct AlignmentGuideGridLayout : RelativeCollectionLayoutModifier {
    
    let spacing: CGFloat
    let columns: Int
    
    public init(spacing: CGFloat, columns: Int) {
        self.spacing = spacing
        self.columns = columns
    }
    
    public func layoutItem(_ content: Content, index: Int, count: Int) -> some View {
        content
            .alignmentGuide(VerticalAlignment.center) {
                let i = Double(index)
                let row : Double = floor(i / Double(columns))
                return -(($0.height + spacing) * row)
            }
            .alignmentGuide(HorizontalAlignment.center) {
                let i = Double(index + 1)
                let row : Double = floor((i - 1) / Double(columns))
                let columns = Double(columns)
                let column = i > columns ? ((i / columns) - row) * columns : i
                return -(($0.width + spacing) * round(column))
            }
    }
    
}
