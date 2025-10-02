import SwiftUIKit


public struct ReversedVStackLayoutExample: View {
    
    public init(){}
    
    private var content: some View {
        ForEach(0...3){ i in
            ContainerRelativeShape()
                .fill(.tint)
                .opacity(Double(i) / 10)
                .overlay {
                    Text(i, format: .number)
                }
        }
    }
    
    public var body: some View {
        ExampleView("Reversed VStack Layout"){
            HStack {
                VStackLayout{
                    content
                }
                ReversedVStackLayout{
                    content
                }
            }
            .padding()
        }
    }
    
}



#Preview {
    ReversedVStackLayoutExample()
        .previewSize()
}
