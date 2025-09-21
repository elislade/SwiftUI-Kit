import SwiftUIKit


public struct InlineEnvironmentValuesExample: View {
    
    @State private var colorScheme: ColorScheme = .light
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            InlineEnvironmentValues { values in
                Rectangle()
                    .fill(.background)
                    .ignoresSafeArea()
                    .overlay{
                        Text(verbatim: "\(values.colorScheme)")
                            .font(.largeTitle.bold())
                    }
            }
            .environment(\.colorScheme, colorScheme)
            
            Divider()
            
            ExampleTitle("Environment Values")
                .padding(.vertical)
            
            ExampleCell.ColorScheme(value: $colorScheme)
        }
    }
}


#Preview("Inline Environment Values") {
    InlineEnvironmentValuesExample()
        .previewSize()
}
