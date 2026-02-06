import SwiftUIKit


public struct InlineStateExample: View {
    
    @State private var identity = false
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Inline State"){
            Rectangle()
                .fill(.tint)
                .ignoresSafeArea()
                .overlay {
                    InlineState(Int.random(in: 0...1_000)){ value in
                        Text(value, format: .number)
                            .font(.largeTitle[.heavy].monospacedDigit())
                    }
                    .id(identity)
                }
        } parameters: {
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Change Identity"){
                    identity.toggle()
                }
            }
            .exampleParameterCell()
        }
    }
    
}

#Preview {
    InlineStateExample()
        .previewSize()
}
