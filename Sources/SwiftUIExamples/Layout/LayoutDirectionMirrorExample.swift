import SwiftUIKit


struct LayoutDirectionMirrorExample: View {
    
    @State private var mirror = false
    
    var body: some View {
        ExampleView(title: "Mirror Layout"){
            VStack(spacing: 0) {
                ForEach(LayoutDirection.allCases, id: \.self){ layout in
                    HStack {
                        Text("\(layout)".splitCamelCaseFormat)
                            .font(.largeTitle.bold())
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .opacity(0.5)
                            .layoutDirectionMirror(enabled: mirror)
                    }
                    .environment(\.layoutDirection, layout)
                    .padding()
                    .font(.title)
                    
                    Divider()
                }
            }
        } parameters: {
            Toggle(isOn: $mirror){
                Text("Is Mirror Enabled")
                    .font(.exampleParameterTitle)
            }
            .padding()
        }
    }
    
}


#Preview("Layout Direction Mirror") {
    LayoutDirectionMirrorExample()
}
