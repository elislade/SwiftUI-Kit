import SwiftUIKit


public struct EdgeHighlightMaterialExample: View {
    
    public init(){ }
    
    public var body: some View {
        ExampleView("Edge Highlight Material"){
            VStack {
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
            #if os(watchOS)
            .ignoresSafeArea()
            #endif
        }
    }
    
}


#Preview {
    EdgeHighlightMaterialExample()
        .previewSize()
}
