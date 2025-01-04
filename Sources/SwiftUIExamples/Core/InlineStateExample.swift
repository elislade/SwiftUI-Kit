import SwiftUIKit


public struct InlineStateExample: View {
    
    @State private var changeIdentity = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            InlineState(UUID()){ id in
                ZStack {
                    Color.random.ignoresSafeArea()
                    Text(id.uuidString)
                        .foregroundStyle(Color.white)
                        .blendMode(.exclusion)
                }
                .id(changeIdentity)
            }
            
            ExampleTitle("Inline State")
                .padding([.horizontal, .top])
            
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Change Identity") { changeIdentity += 1 }
            }
            .padding()
        }
    }
    
}

#Preview {
    InlineStateExample()
        .previewSize()
}
