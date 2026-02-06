import SwiftUIKit


public struct LabelThatFitsExample: View {
    
    @State private var suggestion: LayoutDirectionSuggestion = .useSystemDefault
    
    @State private var height = Clamped(40)
    @State private var width = Clamped(40)
    @State private var prefersTitle: Bool = true
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Label That Fits"){
            Color.clear.onGeometryChangePolyfill(of: \.size){ size in
                height.bounds = (size.height / 10)...size.height
                width.bounds = (size.width / 10)...size.width
            }
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.tint)
                    .frame(width: width.value, height: height.value)
                
                HStack {
                    Label("Leading", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(width: width.value, height: 0)
                    
                    Label("Trailing", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                }
                
                VStack {
                    Label("Top", systemImage: "apple.logo")
                        .frame(maxHeight: .infinity)
                    
                    Rectangle()
                        .frame(width: 0, height: height.value)
                    
                    Label("Bottom", systemImage: "apple.logo")
                        .frame(maxHeight: .infinity)
                }
            }
            .environment(\.layoutDirectionSuggestion, suggestion)
            .labelStyle(
                prefersTitle ? .viewThatFits(preferring: \.title) : .viewThatFits(preferring: \.icon)
            )
        } parameters: {
            VStack {
                LabeledContent {
                    Group {
                        Text(width.value, format: .increment(1)) +
                        Text(" , ") +
                        Text(height.value, format: .increment(1))
                    }
                    .font(.exampleParameterValue)
                } label: {
                    Text("Size")
                        .font(.exampleParameterTitle)
                }

                HStack {
                    Slider($width)
                    Slider($height)
                }
            }
            .exampleParameterCell()
            
            HStack {
                Text("Prefers")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $prefersTitle.animation(.smooth), items: [true, false]){
                    Text($0 ? "Title" : "Icon")
                }
                .frame(width: 130)
                .controlRoundness(1)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirectionSuggestion(value: $suggestion)
            
        }
    }
    
}


#Preview("Label That Fits") {
    LabelThatFitsExample()
        .previewSize()
}
