import SwiftUIKit


public struct InlineEnvironmentValueExample: View {
    
    public init() {}
    
    public var body: some View {
        InlineEnvironmentValue(\.displayScale){ scale in
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    
                    Text("Display Scale ").foregroundColor(.gray) + Text(scale, format: .number)
                }
                .font(.title.bold())
                .background(.regularMaterial)
                
                Divider().ignoresSafeArea()
                
                ExampleTitle("Inline Environment Reader")
                    .padding(.vertical)
            }
        }
    }
    
}


#Preview("Inline Environment Value") {
    InlineEnvironmentValueExample()
        .previewSize()
}
