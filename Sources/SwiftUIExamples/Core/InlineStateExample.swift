import SwiftUIKit


struct InlineStateExample: View {
    
    @State private var changeIdentity = 0
    
    var body: some View {
        VStack(spacing: 0) {
            InlineState(UUID()){ id in
                ZStack {
                    Color.random.ignoresSafeArea()
                    Text(id.uuidString)
                        .foregroundStyle(Color.white)
                        .blendMode(.exclusion)
                }
                .id(changeIdentity)
                .onTapGesture {
                    changeIdentity += 1
                }
            }
            
            ExampleTitle("Inline State")
                .padding()
        }
    }
    
}

#Preview {
    InlineStateExample()
}
