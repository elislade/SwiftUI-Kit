import SwiftUIKit


public struct InlineEnvironmentValuesExample: View {
    
    @State private var colorScheme: ColorScheme = .light
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Inline Environment Values"){
            InlineEnvironmentValues { values in
                Text(verbatim: "\(values.colorScheme)")
                    .font(.largeTitle.bold())
            }
            .preferredColorScheme(colorScheme)
        } parameters: {
            ExampleCell.ColorScheme(value: $colorScheme)
        }
    }
}


#Preview("Inline Environment Values") {
    InlineEnvironmentValuesExample()
        .previewSize()
}
