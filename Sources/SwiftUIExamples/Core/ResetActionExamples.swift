import SwiftUIKit


struct ResetActionExamples: View {
    
    public init() {}
    
    public var body: some View {
        Content()
            .resetActionContext()
    }
    
    struct Content: View {
        
        @Environment(\.reset) private var reset
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    VStack(spacing: nil) {
                        ChildView()
                        
                        ChildView()
                            .resetActionsDisabled()
                        
                        ChildView()
                    }
                    .padding()
                }
                .background(.regularMaterial)
                
                Divider().ignoresSafeArea()

                VStack(spacing: 0) {
                    ExampleTitle("Reset Action")
                        .padding(.vertical)
                    
                    HStack {
                        Button("Reset"){ reset() }
                    }
                    .lineLimit(1)
                    .padding()
                }
            }
        }
        
    }
    
    struct ChildView: View {
        
        @State private var value = 0.0
        
        var body: some View {
            Slider(value: $value)
                .resetAction(active: value != 0){
                    withAnimation(.bouncy){ value = 0 }
                }
        }
    }
    
}


#Preview("ResetAction Example") {
    ResetActionExamples()
        .previewSize()
}
