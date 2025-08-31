import SwiftUIKit


public struct StickyMaskExample: View {
        
    public init(){ }
    
    public var body: some View {
        VStack {
            ScrollView{
                VStack(spacing: 100) {
                    ForEach(0..<4, id: \.self) { i in
                        Cell()
                            .opacity((0.25 * Double(i)) + 0.05)
                    }
                }
                .padding(.vertical, 100)
                .padding(.horizontal, 16)
            }
            .stickyContext()
            .background{ Color.secondary.opacity(0.1) }
            .overlay{
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder()
                    .opacity(0.2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            ExampleTitle("Sticky Category Mask")
        }
        .padding()
    }
    
    
    struct Cell: View {
        
        var body: some View {
            HStack(alignment: .center, spacing: 16) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.tint)
                    .aspectRatio(2, contentMode: .fit)
                    .sticky(edges: .top, inset: 16, categoryMask: .span1)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.tint)
                    .aspectRatio(0.6, contentMode: .fit)
                    .sticky(edges: .top, inset: 16, categoryMask: .span2)
            }
        }
        
    }
    
}


#Preview("Sticky Category Mask") {
    StickyMaskExample()
        .previewSize()
}

fileprivate extension StickyCategoryMask {
    
    static let span1 = StickyCategoryMask(rawValue: 1 << 2)
    static let span2 = StickyCategoryMask(rawValue: 1 << 3)
    static let fullSpan: StickyCategoryMask = [span1, span2]
    
}
