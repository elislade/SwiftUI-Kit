import SwiftUIKit


public struct InlineEnvironmentValueExample: View {
    
    public init() {}
    
    public var body: some View {
        ExampleView("Inline Environment Reader"){
            InlineEnvironmentValue(\.displayScale){ scale in
                ZStack {
                    Color.clear
                    
                    Text("Display Scale ").foregroundColor(.gray) + Text(scale, format: .number)
                }
                .font(.title.bold())
            }
        }
    }
    
}


#Preview("Inline Environment Value") {
    InlineEnvironmentValueExample()
        .previewSize()
}
