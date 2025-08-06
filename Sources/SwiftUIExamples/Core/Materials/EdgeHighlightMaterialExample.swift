import SwiftUIKit


public struct EdgeHighlightMaterialExample: View {
    
    public init(){ }
    
    public var body: some View {
        VStack {
            ExampleTitle("Edge Highlight Material")
            
            EdgeHighlightMaterial(RoundedRectangle(cornerRadius: 14))
            
            HStack {
                EdgeHighlightMaterial(Circle())
                EdgeHighlightMaterial(Rectangle())
                EdgeHighlightMaterial(
                    AsymmetricRoundedRectangle(values: .init(left: 20, right: 12))
                )
            }
            
            EdgeHighlightMaterial(RoundedRectangle(cornerRadius: 14))
        }
        .padding()
        .background{
            Rectangle()
                .fill(.tint)
                .ignoresSafeArea()
                .opacity(0.3)
        }
        #if os(watchOS)
        .ignoresSafeArea()
        #endif
    }
    
}


#Preview {
    EdgeHighlightMaterialExample()
        .previewSize()
}
