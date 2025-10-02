import SwiftUIKit


public struct InlineStateExample: View {
    
    @State private var changeIdentity = 0
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Inline State"){
            InlineState(UUID()){ id in
                ZStack {
                    Color.random.ignoresSafeArea()
                    Text(id.uuidString)
                        .foregroundStyle(Color.white)
                        .blendMode(.exclusion)
                }
                .id(changeIdentity)
            }
        } parameters: {
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Change Identity") { changeIdentity += 1 }
            }
            .exampleParameterCell()
        }
    }
    
}

#Preview {
    InlineStateExample()
        .previewSize()
}
