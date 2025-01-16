import SwiftUIKit


public struct LabelStyleExamples: View {
    
    @State private var suggestion: LayoutDirectionSuggestion = .useSystemDefault
    @State private var size = CGSize(width: 40, height: 40)
    @State private var prefersTitle: Bool = true
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Label That Fits"){
            HStack {
                Label{
                    Text("Leading")
                } icon: {
                    Image(systemName: "apple.logo")
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Label{
                        Text("Top")
                    } icon: {
                        Image(systemName: "apple.logo")
                    }
                    .frame(maxHeight: .infinity)
                    
                    Rectangle()
                        .frame(width: size.width, height: size.height)
                    
                    Label{
                        Text("Bottom")
                    } icon: {
                        Image(systemName: "apple.logo")
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Label{
                    Text("Trailing")
                } icon: {
                    Image(systemName: "apple.logo")
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .environment(\.layoutDirectionSuggestion, suggestion)
            .labelStyle(ViewThatFitsLabelStyle(prefersTitle: prefersTitle))
        } parameters: {
            VStack {
                HStack {
                    Text("Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer(minLength: 0)
                    
                    Group {
                        Text(size.width, format: .number.rounded(increment: 1)) + Text(" , ") + Text(size.height, format: .number.rounded(increment: 1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $size.width, in: 100...800)
                    Slider(value: $size.height, in: 100...800)
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


#Preview("Label Styles") {
    LabelStyleExamples()
        .previewSize()
}
