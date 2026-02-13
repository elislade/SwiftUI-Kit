import SwiftUIKit


public struct TextFieldExample: View {
    
    @FocusState private var focusState
    @State private var isFocused: Bool = false
    @State private var size = ControlSize.regular
    @State private var roundness = 0.5
    @State private var text = ""
    @State private var showLeading = false
    @State private var direction = LayoutDirection.leftToRight
    @State private var disabled = false
    @State private var clearVisibility: TextFieldElementVisibility = .whileEditing
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Text Field"){
            Group {
                if showLeading {
                    TextField(
                        "Search",
                        text: $text,
                        clearButtonVisibility: clearVisibility
                    ){
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 2)
                    }
                } else {
                    TextField(
                        "Search",
                        text: $text,
                        clearButtonVisibility: clearVisibility
                    )
                }
            }
            .padding()
            .font(.body.weight(.semibold))
            .controlSize(size)
            .controlRoundness(roundness)
            .focused($focusState)
            .environment(\.layoutDirection, direction)
            .disabled(disabled)
        } parameters: {
            ExampleSection(isExpanded: true){
                HStack {
                    Toggle(isOn: $disabled){
                        Text("Disabled")
                    }
                    
                    ExampleCell.ControlRoundness(value: $roundness)
                }
                
                HStack {
                    Toggle(isOn: $isFocused){
                        Text("Focus")
                    }
                    .syncValue(_isFocused, _focusState)
                    
                    Toggle(isOn: $showLeading){
                        Text("Show Leading")
                    }
                }
                
                HStack {
                    ExampleCell.ControlSize(value: $size)
                    ExampleMenuPicker(
                        data: TextFieldElementVisibility.allCases,
                        selection: $clearVisibility
                    ){
                        Text("\($0)".splitCamelCaseFormat)
                    } label: {
                        Text("Clear Visibility")
                    }
                }
                
                ExampleCell.LayoutDirection(value: $direction)
            } label: {
                Text("Parameters")
            }
        }
    }
    
}


#Preview("Text Field") {
    TextFieldExample()
        .previewSize()
}
