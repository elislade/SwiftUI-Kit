import SwiftUIKit


public struct ReversedVStackLayoutExample: View {
    
    public init(){}
    
    private var content: some View {
        ForEach(0...3){ i in
            Color.primary
                .opacity(Double(i) / 10)
                .overlay {
                    Text(i, format: .number)
                }
                .border(.red)
        }
    }
    
    public var body: some View {
        VStack {
            ExampleTitle("Reversed VStackLayout")
            
            HStack {
                VStackLayout{
                    content
                }
                ReversedVStackLayout{
                    content
                }
            }
        }
    }
    
}



#Preview {
    ReversedVStackLayoutExample()
        .previewSize()
}
