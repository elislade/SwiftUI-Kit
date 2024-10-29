import SwiftUIKit


struct TextFieldExample: View {
    
    @FocusState private var focusState
    @State private var isFocused: Bool = false
    @State private var size = ControlSize.regular
    @State private var roundness = 0.5
    @State private var text = ""
    @State private var showLeading = false
    @State private var clearVisibility: TextFieldElementVisibility = .whileEditing
    
    var body: some View {
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
        } parameters: {
            HStack{
                Text("Clear Visibility")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $clearVisibility){
                    ForEach(TextFieldElementVisibility.allCases){
                        Text("\($0)".splitCamelCaseFormat).tag($0)
                    }
                }
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $isFocused){
                Text("Focus")
                    .font(.exampleParameterTitle)
            }
            .padding()
            .syncValue(_isFocused, _focusState)
            
            Divider()
            
            Toggle(isOn: $showLeading){
                Text("Show Leading")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.ControlRoundness(value: $roundness)
            
            Divider()
            
            ExampleCell.ControlSize(value: $size)
        }
    }
    
}


#Preview("Text Field") {
    TextFieldExample()
}
